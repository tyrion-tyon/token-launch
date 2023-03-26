// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.15;

import "./interfaces/IPancakeFactory.sol";
import "./interfaces/IPancakePair.sol";
import "./interfaces/IPancakeRouter02.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/Utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TYON_V1 is
    IERC20Upgradeable,
    AccessControlUpgradeable,
    OwnableUpgradeable,
    PausableUpgradeable
{
    using AddressUpgradeable for address;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    mapping(address => uint256) internal _rOwned;
    mapping(address => uint256) internal _tOwned;
    mapping(address => mapping(address => uint256)) internal _allowances;
    mapping(address => uint8) internal _badge;
    mapping(address => bool) internal _isExcludedFromFee;
    mapping(address => bool) internal _isExcluded;
    mapping(address => bool) internal _isLP;

    // Ecosystem Wallets
    address public tyonGrowthX;
    address public tyrionShield;
    address public tyonFundMe;
    address public tyonEcosystemGrowth;

    // Fund Holding Wallets
    address public walletGrowthX;
    address public walletTyrionShiled;

    // token config
    uint16 public _transferTaxfee;
    uint16 public _buySellTaxFee;
    uint16 public _buySellEcosystemFee;
    uint16 public _transferEcosystemFee;

    uint256 public _maxTxAmount; // max amount allowed to transfer
    uint256 public _minBuysellAmount; // min amount allowed to buy or sell.

    // role id
    bytes32 public constant BADGE_MANAGER = keccak256("BADGE_MANAGER");
    bytes32 public constant TAX_MANAGER = keccak256("TAX_MANAGER");

    IPancakeRouter02 public pancakeRouter;
    address public pancakePair;

    uint256 internal _tTotal;
    uint256 internal _rTotal;
    uint256 internal _tFeeTotal;

    uint256 internal _taxFee;
    uint256 internal _previousTaxFee;
    uint256 internal _ecosystemFee;
    uint256 internal _previousEcosystemFee;
    bool internal _tradeFeeEnabled;

    uint8 internal _salePhase;
    address[] internal _excluded;

    uint8 private constant MAX_TX_PERCENT = 40;
    uint16 private constant MAX_FEE_PERCENT = 50 * 10; //50% value mul by 10 to avoid precision error
    uint256 private constant MAX = ~uint256(0);

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    event SalePhaseUpdated(uint8 salePhase);

    // prevent intialization of logic contract.
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    /**
     * @dev initialize the token contract. Minting _totalSupply into owner and growthX account.
     * setting msg sender as DEFAULT_ADMIN_ROLE, MINTER_ROLE, BURNER_ROLE.
     * Note:initializer modifier is used to prevent initialize token twice.
     */
    function initialize(
        address _growthX,
        address _tyrionShield,
        address _fundMe,
        address _ecosystemGrowth,
        address _growthXWallet,
        address _tyrionShieldWallet
    ) public initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        __Pausable_init_unchained();
        __AccessControl_init_unchained();
        __TYON_V1_init_unchained(
            _growthX,
            _tyrionShield,
            _fundMe,
            _ecosystemGrowth,
            _growthXWallet,
            _tyrionShieldWallet
        );
    }

    // internal function to initialize the contract
    function __TYON_V1_init_unchained(
        address _growthX,
        address _tyrionShield,
        address _fundMe,
        address _ecosystemGrowth,
        address _growthXWallet,
        address _tyrionShieldWallet
    ) internal onlyInitializing {
        _name = "TYON";
        _symbol = "TYON";
        _decimals = 9;

        _tTotal = 500000000 * 10 ** 9; // total supply
        _rTotal = (MAX - (MAX % _tTotal)); // total reflection

        // minting initial supply
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);

        _transferTaxfee = 0; // 0%
        _buySellTaxFee = 15; // actual value is 1.5%

        _taxFee = _transferTaxfee;
        _previousTaxFee = _taxFee;

        _buySellEcosystemFee = 10; // actaul value 1%. *10 to acomodate value less than 1%
        _transferEcosystemFee = 5; // 0.5%

        _tradeFeeEnabled = false;
        _ecosystemFee = _transferEcosystemFee;
        _previousEcosystemFee = _ecosystemFee;

        _salePhase = 1; //initial sale phase.

        _maxTxAmount = 5000000 * 10 ** 9; // 5000000 TYON
        _minBuysellAmount = 500 * 10 ** 9; // 500 TYON

        // IPancakeRouter02 _pancakeRouter = IPancakeRouter02(
        //     0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 // pancake router for testnet
        // );
        // // Creating a new pancakeswap pair for this new token
        // pancakePair = IPancakeFactory(_pancakeRouter.factory()).createPair(
        //     address(this),
        //     _pancakeRouter.WETH()
        // );

        // // set the contract variables
        // pancakeRouter = _pancakeRouter;
        // _isLP[pancakePair] = true;

        // assigning variables
        tyonGrowthX = _growthX;
        tyrionShield = _tyrionShield;
        tyonFundMe = _fundMe;
        tyonEcosystemGrowth = _ecosystemGrowth;
        walletGrowthX = _growthXWallet;
        walletTyrionShiled = _tyrionShieldWallet;

        //exclude owner fee wallets and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_growthX] = true;
        _isExcludedFromFee[_fundMe] = true;
        _isExcludedFromFee[_tyrionShield] = true;
        _isExcludedFromFee[_ecosystemGrowth] = true;
        _isExcludedFromFee[_growthXWallet] = true;
        _isExcludedFromFee[_tyrionShieldWallet] = true;
        _isExcludedFromFee[address(this)] = true;

        _badge[_msgSender()] = 1; // master of coin
        _badge[_growthX] = 8; //indicates no badge
        _badge[_tyrionShield] = 8;
        _badge[_fundMe] = 8;
        _badge[_ecosystemGrowth] = 8;
        _badge[_growthXWallet] = 8;
        _badge[_tyrionShieldWallet] = 8;
        _badge[pancakePair] = 8;

        // assigning roles
        _grantRole(DEFAULT_ADMIN_ROLE, owner()); //'default Admin' of roles
        _grantRole(BADGE_MANAGER, owner());
        _grantRole(TAX_MANAGER, owner());

        // exclude owner and walletGrowthX from rewards.
        excludeFromReward(owner());
        excludeFromReward(_growthXWallet);
        excludeFromReward(_tyrionShieldWallet);

        // transfering initial supply
        transfer(_tyrionShieldWallet, 35000000 * 10 ** 9); // 7% of total Supply
        transfer(_growthXWallet, 200000000 * 10 ** 9); // 40% of total supply
    }

    /**
     * @dev to recieve ETH from pancakeV2Router when swaping.
     */
    receive() external payable {}

    /**
     * @dev function to set Tax percentages.
     * @param transferTaxfee tax percentage for standard transfer.
     * @param buySellTaxFee tax percentage for buy/sell transaction.
        - fee value should be multiplied with 10.
        - the caller must be of role TAX_MANAGER.
     */
    function setTaxFeePercent(
        uint16 transferTaxfee,
        uint16 buySellTaxFee
    ) external virtual onlyRole(TAX_MANAGER) {
        require(
            transferTaxfee <= MAX_FEE_PERCENT &&
                buySellTaxFee <= MAX_FEE_PERCENT,
            "Taxfee can't be greater than 50%"
        );
        _transferTaxfee = transferTaxfee;
        _buySellTaxFee = buySellTaxFee;
    }

    /**
     * @dev function to set ecosystem fee percentages.
     * @param buySellEcosystemFee ecosystem fee percentage for buy/sell transaction.
     * @param transferEcosystemFee ecosystem fee percentage for standard transfer.
        - fee value should be multiplied with 10.
        - the caller must be of role TAX_MANAGER.
     */
    function setEcosystemFeePercent(
        uint16 buySellEcosystemFee,
        uint16 transferEcosystemFee
    ) external virtual onlyRole(TAX_MANAGER) {
        require(
            buySellEcosystemFee <= MAX_FEE_PERCENT &&
                transferEcosystemFee <= MAX_FEE_PERCENT,
            "EcosystemFee can't be greater than 50%"
        );
        _buySellEcosystemFee = buySellEcosystemFee;
        _transferEcosystemFee = transferEcosystemFee;
    }

    function setMaxTxPercent(uint256 maxTxPercent) external virtual onlyOwner {
        require(maxTxPercent < MAX_TX_PERCENT, "invalid value");
        _maxTxAmount = (_tTotal * (maxTxPercent)) / (10 ** 2);
    }

    function setMinBuySellAmount(uint256 minToken) external virtual onlyOwner {
        _minBuysellAmount = minToken * 10 ** 9;
    }

    function setCurrentPhase(uint8 phase) external virtual onlyOwner {
        require(phase > 0 && phase < 7, "invalid phase");
        require(_salePhase != phase, "phase already set");
        _salePhase = phase;
        emit SalePhaseUpdated(phase);
    }

    function setBadge(
        address account,
        uint8 badgeId
    ) external virtual onlyRole(BADGE_MANAGER) {
        require(badgeId > 0 && badgeId < 7, "invalid id");
        require(_badge[account] != badgeId, "badge already set");
        _badge[account] = badgeId;
    }

    /**
     * @dev function to withdraw ERC20 tokens trapped on smartcontract.
     * @param amount amount of token reuired to withdraw.
     * @param token address of the ERC20 token smartcontract
        - the caller must be the owner of the contract
     */

    function withdrawToken(
        uint256 amount,
        address token
    ) external virtual onlyOwner {
        IERC20Upgradeable ERC20Token = IERC20Upgradeable(token);
        ERC20Token.safeTransfer(owner(), amount);
    }

    /**
     * @dev function to withdraw all ETH trapped on smartcontract to 
       owner's account.
     */

    function withdraw() external virtual onlyOwner {
        (bool sent, ) = owner().call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    function pause() external virtual onlyOwner {
        _pause();
    }

    function unpause() external virtual onlyOwner {
        _unpause();
    }

    /**
     * @dev function to distribute token as reflection.
     */
    function deliver(uint256 tAmount) external whenNotPaused {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        (uint256 rAmount, , , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - (rAmount);
        _rTotal = _rTotal - (rAmount);
        _tFeeTotal = _tFeeTotal + (tAmount);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function salePhase() external view returns (uint8) {
        return _salePhase;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    function balanceOf(
        address account
    ) external view virtual override returns (uint256) {
        return _balanceOf(account);
    }

    // public functions
    function setLPAddress(address account) public virtual onlyOwner {
        require(!_isLP[account], "account already added");
        _isLP[account] = true;
    }

    function removeLPAddress(address account) public virtual onlyOwner {
        require(_isLP[account], "account already removed");
        _isLP[account] = false;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        require(
            amount <= _allowances[sender][_msgSender()],
            "amount should be less than allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - (subtractedValue)
        );
        return true;
    }

    /**
     * @dev add an account to the excluded list.
     * @param account The account to be excluded from the reward.
     */
    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    /**
     * @dev Removes an account from the excluded list.
     * @param account The account to be included in the reward.
     */
    function includeInReward(address account) public onlyOwner {
        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                delete _tOwned[account];
                delete _isExcluded[account];
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) public onlyOwner {
        require(
            _isExcludedFromFee[account] == false,
            "account already excluded"
        );
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        require(
            _isExcludedFromFee[account] == true,
            "account already included"
        );
        _isExcludedFromFee[account] = false;
    }

    function reflectionFromToken(
        uint256 tAmount,
        bool deductTransferFee
    ) public view returns (uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(
        uint256 rAmount
    ) public view returns (uint256) {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount / (currentRate);
    }

    function getUserBadge(
        address _address
    ) public view virtual returns (string memory __badge) {
        string[7] memory badges = [
            "not_applicable",
            "MasterOfCoins",
            "Pods&Bronns",
            "Sommeliers",
            "Vanguards",
            "Westermen",
            "Khalasaris"
        ];

        if (_badge[_address] > 0 && _badge[_address] < badges.length) {
            return badges[_badge[_address]];
        }
        return badges[0];
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // internal functions
    function _distributeTax(uint256 tTaxCut) internal {
        uint256 currentRate = _getRate();
        uint256 tTaxCutPerWallet = tTaxCut / 4;
        uint256 tTaxCutBalance = tTaxCut - (tTaxCutPerWallet * 3);
        uint256 rTaxCutPerWallet = tTaxCutPerWallet * currentRate;
        uint256 rTaxCutBalance = tTaxCutBalance * currentRate;

        _rOwned[tyonGrowthX] = _rOwned[tyonGrowthX] + (rTaxCutPerWallet);
        if (_isExcluded[tyonGrowthX]) {
            _tOwned[tyonGrowthX] = _tOwned[tyonGrowthX] + tTaxCutPerWallet;
        }

        _rOwned[tyonFundMe] = _rOwned[tyonFundMe] + (rTaxCutPerWallet);
        if (_isExcluded[tyonFundMe]) {
            _tOwned[tyonFundMe] = _tOwned[tyonFundMe] + tTaxCutPerWallet;
        }

        _rOwned[tyonEcosystemGrowth] =
            _rOwned[tyonEcosystemGrowth] +
            (rTaxCutPerWallet);
        if (_isExcluded[tyonEcosystemGrowth]) {
            _tOwned[tyonEcosystemGrowth] =
                _tOwned[tyonEcosystemGrowth] +
                tTaxCutPerWallet;
        }

        _rOwned[tyrionShield] = _rOwned[tyrionShield] + (rTaxCutBalance);
        if (_isExcluded[tyrionShield]) {
            _tOwned[tyrionShield] = _tOwned[tyrionShield] + tTaxCutBalance;
        }
    }

    function removeAllFee() internal {
        if (_taxFee == 0 && _ecosystemFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousEcosystemFee = _ecosystemFee;

        _taxFee = 0;
        _ecosystemFee = 0;
    }

    function enableTradingFee() internal {
        if (_ecosystemFee == _buySellEcosystemFee && _taxFee == _buySellTaxFee)
            return;

        _ecosystemFee = _buySellEcosystemFee;
        _taxFee = _buySellTaxFee;
        _tradeFeeEnabled = true;
    }

    function disableTradingFee() internal {
        if (
            _ecosystemFee == _transferEcosystemFee && _taxFee == _transferTaxfee
        ) return;

        _ecosystemFee = _transferEcosystemFee;
        _taxFee = _transferTaxfee;
        _tradeFeeEnabled = false;
    }

    function restoreAllFee() internal {
        _taxFee = _previousTaxFee;
        _ecosystemFee = _previousEcosystemFee;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal whenNotPaused {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (from != owner() && to != owner())
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) internal {
        if (_isLP[sender] || _isLP[recipient]) {
            require(
                amount >= _minBuysellAmount,
                "transfer amount should be greater than minBuysellAmount"
            );
            enableTradingFee();
        }
        if (!takeFee) removeAllFee();
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (_badge[recipient] == 0) _badge[recipient] = _salePhase; //assigning badge as per the sale phase

        if (!takeFee) restoreAllFee();
        if (_tradeFeeEnabled) disableTradingFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) internal {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTaxCut
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + (rTransferAmount);
        _distributeTax(tTaxCut);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) internal {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTaxCut
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - (tAmount);
        _rOwned[sender] = _rOwned[sender] - (rAmount);
        _tOwned[recipient] = _tOwned[recipient] + (tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient] + (rTransferAmount);
        _distributeTax(tTaxCut);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) internal {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTaxCut
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _distributeTax(tTaxCut);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) internal {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTaxCut
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _distributeTax(tTaxCut);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _balanceOf(
        address account
    ) internal view virtual returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) internal virtual {
        _rTotal = _rTotal - (rFee);
        _tFeeTotal = _tFeeTotal + (tFee);
    }

    function _getValues(
        uint256 tAmount
    )
        internal
        view
        returns (uint256, uint256, uint256, uint256, uint256, uint256)
    {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTaxCut) = _getTValues(
            tAmount
        );
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tTaxCut,
            _getRate()
        );
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTaxCut);
    }

    function _getTValues(
        uint256 tAmount
    ) internal view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tTaxCut = calculateEcosystemFee(tAmount);
        uint256 tTransferAmount = tAmount - tFee - tTaxCut;
        return (tTransferAmount, tFee, tTaxCut);
    }

    function _getRate() internal view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / (tSupply);
    }

    function _getCurrentSupply() internal view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply - (_rOwned[_excluded[i]]);
            tSupply = tSupply - (_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal / (_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function calculateTaxFee(uint256 _amount) internal view returns (uint256) {
        return (_amount * (_taxFee)) / (10 ** 3);
    }

    function calculateEcosystemFee(
        uint256 _amount
    ) internal view returns (uint256) {
        return (_amount * (_ecosystemFee)) / (10 ** 3);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tTaxCut,
        uint256 currentRate
    ) internal pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * (currentRate);
        uint256 rFee = tFee * (currentRate);
        uint256 rTaxCut = tTaxCut * (currentRate);
        uint256 rTransferAmount = rAmount - (rFee) - (rTaxCut);
        return (rAmount, rTransferAmount, rFee);
    }
}
