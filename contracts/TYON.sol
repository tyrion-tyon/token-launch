// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

// pragma solidity >=0.5.0;
interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// pragma solidity >=0.5.0;
interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;
interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// pragma solidity >=0.6.2;
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract TYON_V1 is
    IERC20Upgradeable,
    AccessControlUpgradeable,
    OwnableUpgradeable,
    PausableUpgradeable
{
    using AddressUpgradeable for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint8) private _badge;
    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    address public tyonGrowthX;
    address public tyonShield;
    address public tyonFundMe;
    address public tyonEcosystemGrowth;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _transferTaxfee;
    uint256 public _buySellTaxFee;

    uint256 private _taxFee;
    uint256 private _previousTaxFee;

    uint256 public _buySellEcosystemFee;
    uint256 public _transferEcosystemFee;

    uint256 private _ecosystemFee;
    uint256 private _previousEcosystemFee;

    uint256 private _salePhase;

    bytes32 public constant BADGE_MANAGER = keccak256("BADGE_MANAGER");
    bytes32 public constant TAX_MANAGER = keccak256("TAX_MANAGER");

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    uint256 public _maxTxAmount;
    uint256 public _minBuysellAmount;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SalePhaseUpdated(uint8 salePhase);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    // prevent intialization of logic contract.
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(
        address _growthX,
        address _tyonShield,
        address _fundMe,
        address _ecosystemGrowth
    ) public initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        __Pausable_init_unchained();
        __AccessControl_init_unchained();
        __TYON_V1_init_unchained(
            _growthX,
            _tyonShield,
            _fundMe,
            _ecosystemGrowth
        );
    }

    function __TYON_V1_init_unchained(
        address _growthX,
        address _tyonShield,
        address _fundMe,
        address _ecosystemGrowth
    ) internal onlyInitializing {
        _name = "TYON";
        _symbol = "TYON";
        _decimals = 9;

        _tTotal = 500000000 * 10**6 * 10**9;
        _rTotal = (MAX - (MAX % _tTotal));

        _rOwned[_msgSender()] = _rTotal / 2;
        _rOwned[_growthX] = _rTotal / 2;

        _transferTaxfee = 0;
        _buySellTaxFee = 15;

        _taxFee = _transferTaxfee;
        _previousTaxFee = _taxFee;

        _buySellEcosystemFee = 10; // actaul value 1%. *10 to acomodate value less than 1%
        _transferEcosystemFee = 5; // 0.5%

        _ecosystemFee = _transferEcosystemFee;
        _previousEcosystemFee = _ecosystemFee;

        _salePhase = 1;

        _maxTxAmount = 5000000 * 10**6 * 10**9;
        _minBuysellAmount = 500 * 10**9;

        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
        //     0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 //pancakeswap BNB testnet
        // );
        // Create a uniswap pair for this new token
        uniswapV2Pair = 0x1947CeF08E9B7D8eE1a27a804B8ace5B9db11b19; //IUniswapV2Factory(_uniswapV2Router.factory())
        //     .createPair(address(this), _uniswapV2Router.WETH());

        // // set the rest of the contract variables
        //uniswapV2Router = _uniswapV2Router;

        tyonGrowthX = _growthX;
        tyonShield = _tyonShield;
        tyonFundMe = _fundMe;
        tyonEcosystemGrowth = _ecosystemGrowth;

        //exclude owner fee wallets and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_growthX] = true;
        _isExcludedFromFee[_fundMe] = true;
        _isExcludedFromFee[_tyonShield] = true;
        _isExcludedFromFee[_ecosystemGrowth] = true;
        _isExcludedFromFee[address(this)] = true;

        _badge[_msgSender()] = 1;
        _badge[_growthX] = 8; //indicates no badge
        _badge[_tyonShield] = 8;
        _badge[_fundMe] = 8;
        _badge[_ecosystemGrowth] = 8;

        _grantRole(DEFAULT_ADMIN_ROLE, owner()); //assigning owner as the default Admin of roles
        _grantRole(BADGE_MANAGER, owner());
        _grantRole(TAX_MANAGER, owner());

        // exclude owner and growthX from reward.
        excludeFromReward(owner());
        excludeFromReward(_growthX);

        emit Transfer(address(0), _msgSender(), _tTotal / 2);
        emit Transfer(address(0), _growthX, _tTotal / 2);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function setTaxFeePercent(uint256 transferTaxfee, uint256 buySellTaxFee)
        external
        onlyRole(TAX_MANAGER)
    {
        _transferTaxfee = transferTaxfee;
        _buySellTaxFee = buySellTaxFee;
    }

    function setEcosystemFeePercent(
        uint256 buySellEcosystemFee,
        uint256 transferEcosystemFee
    ) external onlyRole(TAX_MANAGER) {
        _buySellEcosystemFee = buySellEcosystemFee;
        _transferEcosystemFee = transferEcosystemFee;
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
        _maxTxAmount = (_tTotal * (maxTxPercent)) / (10**2);
    }

    function setMinBuySellAmount(uint256 minToken) external onlyOwner {
        _minBuysellAmount = minToken * 10**9;
    }

    function setCurrentPhase(uint8 phase) external onlyOwner {
        require(phase > 0 && phase < 6, "invalid phase");
        if (_salePhase != phase) _salePhase = phase;
        emit SalePhaseUpdated(phase);
    }

    function setBadge(uint8 badgeId, address account)
        external
        virtual
        onlyRole(BADGE_MANAGER)
    {
        require(badgeId > 0 && badgeId < 6, "invalid id");
        if (_badge[account] != badgeId) _badge[account] = badgeId;
    }

    /**
     * @dev Pauses the token contract.
     *
     * See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must be the owner of the contract.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses the token contract.
     *
     * See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must be owner of the contract.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

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

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function getUserBadge(address _address)
        external
        view
        returns (string memory __badge)
    {
        if (_badge[_address] == 1) {
            return "MasterOfCoins";
        }
        if (_badge[_address] == 2) {
            return "Pods&Bronns";
        }
        if (_badge[_address] == 3) {
            return "Sommeliers";
        }
        if (_badge[_address] == 4) {
            return "Vanguards";
        }
        if (_badge[_address] == 5) {
            return "Freefolks";
        }
        return "not Applicable";
    }

    // public functions
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - (subtractedValue)
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount / (currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) public onlyOwner {
        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
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
        _tOwned[recipient] = _tOwned[recipient] - (tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient] - (rTransferAmount);
        _distributeTax(tTaxCut);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - (rFee);
        _tFeeTotal = _tFeeTotal + (tFee);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
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

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tTaxCut = calculateEcosystemFee(tAmount);
        uint256 tTransferAmount = tAmount - tFee - tTaxCut;
        return (tTransferAmount, tFee, tTaxCut);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tTaxCut,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount * (currentRate);
        uint256 rFee = tFee * (currentRate);
        uint256 rTaxCut = tTaxCut * (currentRate);
        uint256 rTransferAmount = rAmount - (rFee) - (rTaxCut);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / (tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
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

    function _distributeTax(uint256 tTaxCut) private {
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
        _rOwned[tyonShield] = _rOwned[tyonShield] + (rTaxCutBalance);
        if (_isExcluded[tyonShield]) {
            _tOwned[tyonShield] = _tOwned[tyonShield] + tTaxCutBalance;
        }
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return (_amount * (_taxFee)) / (10**3);
    }

    function calculateEcosystemFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return (_amount * (_ecosystemFee)) / (10**3);
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _ecosystemFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousEcosystemFee = _ecosystemFee;

        _taxFee = 0;
        _ecosystemFee = 0;
    }

    function enableTradingFee() private {
        if (_ecosystemFee == _buySellEcosystemFee && _taxFee == _buySellTaxFee)
            return;

        _ecosystemFee = _buySellEcosystemFee;
        _taxFee = _buySellTaxFee;
    }

    function disableTradingFee() private {
        if (
            _ecosystemFee == _transferEcosystemFee && _taxFee == _transferTaxfee
        ) return;

        _ecosystemFee = _transferEcosystemFee;
        _taxFee = _transferTaxfee;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _ecosystemFee = _previousEcosystemFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private whenNotPaused {
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
    ) private {
        if (sender == uniswapV2Pair || recipient == uniswapV2Pair) {
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

        if (_badge[recipient] == 0) _badge[recipient] == _salePhase; //assigning badge as per the sale phase

        if (!takeFee) restoreAllFee();
        if (sender == uniswapV2Pair || recipient == uniswapV2Pair)
            disableTradingFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
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

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
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
    ) private {
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
}
