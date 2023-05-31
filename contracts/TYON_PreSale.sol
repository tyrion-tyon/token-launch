 //SPDX-License-Identifier: MIT
pragma solidity 0.8.19; 
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
contract presale is Ownable, ReentrancyGuard{
    
    using SafeERC20 for IERC20;

    address public presaleWallet; // Wallet from which tokens will be sent to users
    address public bnbReceiver; // wallet which recieve all bnb from sales
    uint256 public rate; // how much tokens per bnb
    uint256 public decimals; // token decimals
    uint256 public maxBNBperWallet; // max BNB contribution per wallet
    uint256 public minBNBperWallet; // min BNB contribution per wallet
    uint256 public totalBNBRaised; // total BNB Raised
    
    uint256 public totalTokensSold; // total tokens sold
    uint256 public HardCapBNB; // Hard cap
    uint256 public saleEndTime; // sale end time
    bool public isSaleLive; // sale is live or not
    IERC20 public token;
               //how much a user has contributed
    mapping (address => uint256) public userContributed;

    event tokensBought (uint256 bnbContribution, uint256 tokensSent);
    constructor (){
        token = IERC20 (0x7Ee43f72b5431082993AE81356472AfbB42F9dAc); //TYON
        presaleWallet = 0x3dE196bb9B3fc92c8B20CFAb921934Bf88971533;
        bnbReceiver = msg.sender;
        rate = 8800;
        decimals = 1000000000;
        maxBNBperWallet = 10 ether; // 10 BNB
        minBNBperWallet = 0.1 ether; // 0.1 BNB
        HardCapBNB = 300 ether; // 300 BNB
        isSaleLive = false;
        saleEndTime = 1716764862;
    }
    
    ///@dev owner update end time for sale
    ///@param newEndDate: new time in unixtimestamp
    function updateSaleEndTime (uint256 newEndDate) external onlyOwner {
        saleEndTime = newEndDate;
    }

    ///@dev set sale status
    ///@param value: true to make sale live, false to disable sale
    function toggleSaleStatus (bool value) external  onlyOwner {
        isSaleLive = value;
    }
    
    ///@dev set new hard cap
    ///@param newAmount: new hard cap amount in wei format
    function updateHardCap (uint256 newAmount) external onlyOwner {
        HardCapBNB = newAmount;
    }

    ///@dev set min and max wallet limit ( input in wei)
    ///@param min: min bnb amount that  a user need to spent
    ///@param max: max bnb amount that a user can spent
    function updateMinandMaxWalletLimit (uint256 min, uint256 max) external onlyOwner {
        minBNBperWallet = min;
        maxBNBperWallet = max;
    }

    ///@dev update presale wallet address
    ///@param pWallet: set new address from where token will be distributed to users
    ///@param bWallet: set new address for bnb reciever
    function updatePresaleAndBNBRecieverWallet (address pWallet, address bWallet) external onlyOwner {
        require (pWallet != address(0) && bWallet != address(0), "zero wallet is not allowed");
        presaleWallet = pWallet;
        bnbReceiver = bWallet;
    }

    ///@dev update the token price per BNB
    ///@notice 100 as input means 100 tokens per BNB
    ///@param _rate: update the token price per BNB
    function updatePrice (uint256 _rate) external onlyOwner {
        rate = _rate;
    }

    ///@notice user can buy tokens using this function
    /// Requirements --
    /// sale must be live
    /// sale end time should not passed
    /// amount must be in multiple of minBNBPerWallet
    /// total amount contributed must be less than maxBNBPerWallet allowed
    /// user can contribute till hardcap reached
    function buyTokens () public payable nonReentrant{
        preValidatePurchase(msg.value, msg.sender);
        uint256 tokenToBuy = (msg.value * rate) / decimals;
        ///sending bnb to designated wallet
        (bool sent,) = bnbReceiver.call{value: msg.value}("");
        require(sent, "bnb transfer failed");
        totalBNBRaised = totalBNBRaised + msg.value;
        totalTokensSold = totalTokensSold + tokenToBuy;
        userContributed[msg.sender] = userContributed[msg.sender] + msg.value;
        /// sending tokens to user
        token.safeTransferFrom(presaleWallet, msg.sender, tokenToBuy);
        emit tokensBought(msg.value, tokenToBuy);

    }
    
    ///@notice internal functions to check all the requirements assigned by buy tokens function
    function preValidatePurchase (uint256 bnb, address user)  internal view {
        require (isSaleLive, "sale is  not live yet");
        require (block.timestamp < saleEndTime, "sale is already over");
        require (bnb >= minBNBperWallet && bnb <= maxBNBperWallet - userContributed[user], "amount must be within min and max range");
        require (bnb + totalBNBRaised <= HardCapBNB, "Hardcap Exceeded" );
        
    }
    ///@notice receive any external bnb and process the buy tokens
    receive ()external payable {
        buyTokens();
    }    
}