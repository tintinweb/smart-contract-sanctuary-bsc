/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PreSale {
    using SafeMath for uint256;

    address public constant token = 0xbCD7A7ccaD6D875189529fc5F4b12eBb66513129;

    address payable internal treasury;
    uint256 public treasuryBalance;

    bool public sale = true;
    uint256 public pricePerToken = 0.00009e18;
    uint256 public minimumTokensToBuy = 100e18;
    uint256 public airdrops;
    uint256 public airdropsDistributed;
    uint256 public airdropsTransfered;

    mapping(address => uint256) public airdropForWallets;
    mapping(address => bool) public airdropTransfered;

    uint256 private affiliateCommission;
    uint256 public minTokensRequiredForAffiliating = 1e18;
    mapping(uint256 => uint256) public affiliateCommissionByLevel;
    mapping(address => uint256) private uplines;
    mapping(address => uint256) public promoters;

    uint256 internal unlocked = 1;

    modifier nonReentrant() {
        require(unlocked == 1, "no re-entrancy");
        unlocked = 2;
        _;
        unlocked = 1;
    }

    event Sold(address indexed buyer, uint payed, uint recieved);
    event Commission(address indexed affiliate, uint256 indexed level, uint amount);

    function setTreasury(address payable _newTreasury) external returns (bool) {
        require(msg.sender == treasury, "Invalid treasury");
        treasury = _newTreasury;
        return true;
    }

    function setPricePerToken(uint _price) external {
        require(msg.sender == treasury, "Invalid treasury");
        require(_price > 0, "Invalid price value");
        pricePerToken = _price;
    }

    function setMininmumTokensToBuy(uint _amount) external {
        require(msg.sender == treasury, "Invalid treasury");
        require(_amount > 0, "Invalid amount");
        minimumTokensToBuy = _amount;
    }

    function setAirdrops(uint _amount) external {
        require(msg.sender == treasury, "Invalid treasury");
        require(_amount >= airdropsDistributed && _amount <= IBEP20(token).balanceOf(address(this)) - airdropsDistributed, "Invalid amount");
        airdrops = _amount;
    }

    function setAirdropWallets(address[] memory _wallets, uint256 _amountToAirdrop) external {
        require(msg.sender == treasury, "Invalid treasury");
        require(_wallets.length > 0 && _wallets.length <= 100, "Invalid wallets list");
        uint256 _totalAirdrops = _amountToAirdrop.mul(_wallets.length);
        require(_totalAirdrops > 0 && _totalAirdrops <= airdrops - airdropsDistributed, "Invalid airdrop amount");
        
        uint256 _distributed;

        for (uint i; i < _wallets.length; i++) {   
            if(airdropTransfered[_wallets[i]] == false && airdropForWallets[_wallets[i]] == 0) {
                airdropForWallets[_wallets[i]] = _amountToAirdrop;
                _distributed += _amountToAirdrop;
            }    
        }

        airdropsDistributed += _distributed;    
    }

    function removeAirdrop(address[] memory _wallets) external {
        require(msg.sender == treasury, "Invalid treasury");
        require(_wallets.length > 0 && _wallets.length <= 100, "Invalid wallets list");

        uint256 _removed;
        
        for (uint i; i < _wallets.length; i++) { 
            if(airdropTransfered[_wallets[i]] == false) {
                _removed += airdropForWallets[_wallets[i]];
                airdropForWallets[_wallets[i]] = 0;
            }    
        }

        airdropsDistributed -= _removed;    
    }

    function setPromoter(address[] memory _wallets, uint256 _multiplier) external nonReentrant returns (bool) {
        require(msg.sender == treasury, "Invalid treasury");
        require(_multiplier >= 1 && (affiliateCommissionByLevel[1] * _multiplier) <= 30, "Invalid commission multiplier");
        for (uint i; i < _wallets.length; i++) {   
            promoters[_wallets[i]] = _multiplier;
        }
        return true;
    }

    function removePromoter(address[] memory _wallets) external nonReentrant returns (bool) {
        require(msg.sender == treasury, "Invalid treasury");
        for (uint i; i < _wallets.length; i++) {   
            promoters[_wallets[i]] = 0;
        }
        return true;
    }

    function setMinTokensRequiredForAffiliating(uint256 _minTokensRequiredForAffiliating) external returns (bool) {
        require(msg.sender == treasury, "Invalid treasury");        
        minTokensRequiredForAffiliating = _minTokensRequiredForAffiliating;
        return true;   
    }

    function setUplineLevelCommission(uint256 _level, uint256 _percentage) external nonReentrant {
        require(msg.sender == treasury, "Invalid treasury");
        require(_level >= 1 && _level <= 3, "Invalid level");
        uint256 _updatedAffiliateCommission = (affiliateCommission - affiliateCommissionByLevel[_level]) + _percentage;
        require(_updatedAffiliateCommission <= 25, "Affiliate commission percentage exceeds maximum limit");
        require(_percentage > affiliateCommissionByLevel[_level +1], "Commission should be bigger than the upper level");
        affiliateCommission = _updatedAffiliateCommission;
        affiliateCommissionByLevel[_level] = _percentage;
    }

    function startSale() external {
        require(IBEP20(token).balanceOf(address(this)) > 1e18, "No enough balance");
        require(msg.sender == treasury, "Invalid treasury");
        sale = true;
    }

    function endSale() external {
        require(msg.sender == treasury, "Invalid treasury");
        sale = false; 
    }

    constructor() {
        treasury = msg.sender;
        affiliateCommission = 18;
        affiliateCommissionByLevel[1] = 12;
        affiliateCommissionByLevel[2] = 7;
        affiliateCommissionByLevel[3] = 2;
        affiliateCommissionByLevel[4] = 1;        
    }

    function getAvailableForSale() external view returns (uint256) {
        return IBEP20(token).balanceOf(address(this)) - (airdrops - airdropsTransfered);
    }

    function getUndistributedAirdrops() external view returns (uint256) {
        return airdrops - airdropsDistributed;
    }

    function getUntransferedAirdrops() external view returns (uint256) {
        return airdropsDistributed - airdropsTransfered;
    }

    function getAmountToSell(uint _amount) external view returns (uint256) {       
        uint256 _availableForSale = IBEP20(token).balanceOf(address(this)) - (airdrops - airdropsTransfered);
        return min(_amount.div(pricePerToken, "overflow") * 1e18, _availableForSale);
    }

    function getAmountToPay(uint _amount) external view returns (uint256) {    
        return _amount.div(1e18, "").mul(pricePerToken);
    }

    function getWalletCommissions(address _wallet) external view returns (uint256) {
        return uint(uplines[_wallet]>>160);
    }

    function buy(address _referredBy) external payable nonReentrant {
        require(sale == true, "Token sale ended");

        if(promoters[_referredBy] == 0) {
            require(IBEP20(token).balanceOf(_referredBy) >= minTokensRequiredForAffiliating && _referredBy != address(this) && _referredBy != address(0) && _referredBy != msg.sender, "Invalid affiliate");
        }

        uint256 _payed = msg.value;
        uint256 _availableForSale = IBEP20(token).balanceOf(address(this)) - (airdrops - airdropsTransfered);

        require(_payed > 0, "Invalid payment");

        uint256 _tokens = min(_payed.div(pricePerToken, "overflow") * 1e18, _availableForSale);
        require(_tokens >= minimumTokensToBuy && _tokens <= _availableForSale, "Invalid amount of tokens");               
        uint256 _exactPayment = _tokens.div(1e18, "").mul(pricePerToken);        
        uint256 _upline = uplines[msg.sender];
        
        address _uplineWallet;
        uint256 _commissions;
        
        if(uint160(_upline>>0) == 0) {

            _uplineWallet = _referredBy;

            uint256 _newUplineData  = uint160(_referredBy);
                    _newUplineData |= uint(_upline>>160)<<160;

            uplines[msg.sender] = _newUplineData;
        } else {
            _uplineWallet = address(uint160(_upline>>0));
            _referredBy = _uplineWallet;
        }

        for(uint256 _level = 1; _level < 5; _level++) {
           if(_uplineWallet != address(0)) {
               if(_uplineWallet != msg.sender) {
                   uint256 _uplineWalletData = uplines[_uplineWallet];
                   uint256 _uplineWalletCommission = ((_exactPayment * _affiliateCommissionPercentage(_uplineWallet, _level)) / 100);
                   uint256 _newUplineWalletData  = uint160(_uplineWalletData>>0);
                           _newUplineWalletData |= uint(_uplineWalletData>>160) + _uplineWalletCommission<<160;
            
                   uplines[_uplineWallet] = _newUplineWalletData;
                   emit Commission(_uplineWallet, _level, _uplineWalletCommission);
            
                   _commissions += _uplineWalletCommission;   
                   _uplineWallet = address(uint160(_uplineWalletData>>0));
               }
           } else {
               _level = 10;
           }    
        }  
        
        treasuryBalance += (_exactPayment - _commissions);
        IBEP20(token).transfer(msg.sender, _tokens);
        emit Sold(msg.sender, _exactPayment, _tokens);

        if(msg.value > 0 && msg.value > _exactPayment) {
            msg.sender.transfer(msg.value.sub(_exactPayment, "overflow"));
        }
    } 
    
    function airdropTransfer() external nonReentrant returns (bool) {
        uint256 _amount = airdropForWallets[msg.sender];
        require(_amount > 0 && airdropTransfered[msg.sender] == false, "No airdrops for this wallet");
        airdropTransfered[msg.sender] = true;
        airdropForWallets[msg.sender] = 0;
        airdropsTransfered += _amount;
        IBEP20(token).transfer(msg.sender, _amount);
        return true;
    }

    function withdrawAffiliateCommission() external nonReentrant returns (bool) {
        uint256 _upline = uplines[msg.sender];
        uint256 _amount = uint112(_upline>>160);
        require(_amount > 0, "No enough commissions");
        uplines[msg.sender] = uint160(_upline>>0);
        msg.sender.transfer(_amount);
        return true;
    }

    function transferTokens(address _wallet, uint256 _amount) external nonReentrant returns (bool) {
        require(msg.sender == treasury, "Invalid treasury");
        require(_amount > 0, "Invalid amount");
        IBEP20(token).transfer(_wallet, _amount);
        return true;
    }

    function transferTreasuryBalance(address payable _wallet, uint256 _amount) external nonReentrant returns (bool) {
        require(msg.sender == treasury, "Invalid treasury");
        require(_amount > 0 && _amount <= treasuryBalance, "No enough treasury balance");
        treasuryBalance = treasuryBalance.sub(_amount, "No enough balance");
        _wallet.transfer(_amount);
        return true;
    }

    function _affiliateCommissionPercentage(address _upline, uint256 _level) internal view returns (uint256) {
        if(promoters[_upline] == 0) {
            return affiliateCommissionByLevel[_level];
        } else {
            return min(affiliateCommissionByLevel[_level] * promoters[_upline], 25);
        }    
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
}