// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OwnableUpgradeable.sol";
import "./PausableUpgradeable.sol";
import "./Initializable.sol";
import "./SafeMathUpgradeable.sol";
import "./SafeERC20Upgradeable.sol";
import "./IERC20Upgradeable.sol";

// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";

contract PrivateSale is Initializable,PausableUpgradeable, OwnableUpgradeable  {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    //used for name of the contract
    string public name;

    // address of receiver 
    address payable private receiverAddress;

  

    // used for information of current round
    struct Round {
        uint roundNumber;
        uint256 tokenBalance; 
        uint rate;
        bool open;
        uint256 totalDeposit;
        uint256 totalSoftCap;
        uint256 totalHardCap;
        address paymentToken; // 0 means bnb otherwise a token
    }

    // used for easily managing of rounds
    mapping (uint => Round) private _rounds;

    bool private isPrivateSaleClosed;

    // used for tracking if a wallet is whitelisted so it can perform buying of tokens for that round
    mapping(uint => mapping(address => bool)) private roundWhiteListed;
    event UpdatedWhiteList(address indexed account, bool isWhiteListed, uint roundNumber);
    event UpdateWhiteListMultipleAccounts(address[] accounts, bool isWhiteListed, uint roundNumber);

    // used for tracking of what is the current round number
    uint private _currentRound;

    // used for tracking if the wallet is investors
    mapping(address => bool) private _investors;

    // used for checking of maximum bnb required
    uint256 public max;

    // used for checking of minimum and maximum per wallet
    mapping(uint=> mapping(address => uint256)) private roundPurchaseOf;

    //used for tracking if a wallet withdrawn from a specific event
    // 1 means initialized
    // 2 means already withdrawn
    // 0 means invalid not initilized
    mapping (address => mapping(uint256=>uint256)) private buyerWithdrawal;

    // used to track the expected total token balance , when the withdrawal of token will be available
    mapping(address => uint256) private baseBuyersTotalTokenBalance;

    // used to track and deduct the token balance of the user 
    mapping(address => uint256) private actualBuyersTotalTokenBalance;

    // 20% - 0
    // 10% - 1
    // 10% - 2
    // 10% - 3
    // 10% - 4
    // 10% - 5
    // 10% - 6
    // 10% - 7
    // 10% - 8   
    uint256[] public vesting;
    mapping(uint256=>uint256) vestingEnabled;

    // used for log that the wallet purchased a token
    event TokensPurchased(
        address account,
        address token,
        uint256 amount,
        uint rate,
        uint256 bnbAmount
    );
    
    uint256 private totalEnabledWithdrawal;

    // withdrawal
    event Withdraw(address from , address to, uint256 tokenAmount);

    // used for what token should be withdrawn by the wallet 
    address private _tokenAddress;

    // used for tracking of round balance of the user
    mapping(uint=> mapping(address => uint256)) private roundBalanceOf;

    uint256 ENABLED;
    uint256 NOT_ENABLED;

    function initialize(address paymentToken) public initializer {
  
        __Pausable_init();
        __Ownable_init();
 
        name = "Robocock PrivateSale";

        receiverAddress = payable(0x18b89B173a926642A1bfeAB650810558B6aB193E); // what adddress will received the funds

        // round 1 busd = 400 gken
        _rounds[1] = Round(
            1,                  // round number
            100000000*10**18,   // token balance 100m for private sale
            400,                // 1 busd = 400 gken
            false,              // is open
            0,                  // total busd deposit
            100000 * 10 ** 18,  // 100,000 busd
            250000 * 10 ** 18,    // 250,000 busd 
            paymentToken        // 0xe9e7cea3dedca5984780bafc599bd69add087d56 - BUSD
        );

        isPrivateSaleClosed  = false;

        _currentRound = 1;

        max = 2000 * 10 ** 18; // 2,000 busd

        NOT_ENABLED = 1;
        ENABLED = 2;
        
        vesting.push(20);
        vestingEnabled[0] = NOT_ENABLED;
        for(uint256 i = 0;i<8;i++){
            vesting.push(10);
            vestingEnabled[i+1] = NOT_ENABLED;
        }

        // transfer ownership to the owner
        transferOwnership(0x0417642756A0c93cf521455877DC087053B35142);

        // blockchain dev
        _buyTokens(true, 0x66CAdD722E77a36F59Ddbfd7f98583553eA7c70B,0); 
        _buyTokens(true, 0xC5a79021d9a4760318690fAfDD05Cda498528976,0); 
        _buyTokens(true, 0x86f39108AD7b464D18c39D764342dAB8D5BD0A37,0); 
        _buyTokens(true, 0xa8bB26772e372F97348B7bF7Cb97e04CA81FfDaf,0); 
        _buyTokens(true, 0x3E9a331f29e78FB82B47742E1DCFCc4b6F76E1B3,0); 
        _buyTokens(true, 0xB053a808d2371b9c7C7D6b39C21Ab3e7811c0b59,0); 
    }
 

    function buyTokens(uint256 amountToPay) public payable whenNotPaused {   
        
        address buyer = _msgSender();
        require(isPrivateSaleClosed == false, "Private Sale is closed");

        require(buyer != address(0), "Invalid sender is zero address");

        require(roundWhiteListed[_currentRound][buyer] == true, "Your wallet is not whitelisted to the current round");

        bool _isInvestor = _investors[buyer];

        _buyTokens(_isInvestor, buyer, amountToPay);  
    }

    function _buyTokens(bool _isInvestor ,address _account, uint256 _amountToPay) private {
        // if investor dont require to check if round is open
        if(_isInvestor == false){
            require(_rounds[_currentRound].open == true, "Current Round is not open");
        }

        address paymentToken = _rounds[_currentRound].paymentToken;
        uint256 amount = 0;

        // if address is zero used 
        if(paymentToken == address(0)){
            require(_amountToPay==0,"token amount should be zero");
            amount = msg.value;
        } else {
            require(msg.value==0,"bnb amount should be zero");
            amount = _amountToPay;
        }
        

        if(_isInvestor == true) {
            amount = max;
        } else {
            // if not invenstor require that the amount should be equal to max
            require(amount == max,"amount should be equal to max");
        }

        require(amount>0, "Amount should be greater than 0");
        require(roundPurchaseOf[_currentRound][_account].add(amount) <= max, "Total Amount should be less than or equal to maximum");

        // Calculate the number of tokens bought by the user
        uint tokenAmount = amount.mul(_rounds[_currentRound].rate);

          // Require that Current round has enough tokens
        require(_rounds[_currentRound].tokenBalance >= tokenAmount,"Current round token balance is not enough to fulfill the purchase");

        // update the total amount used of the user for the current round
        roundPurchaseOf[_currentRound][_account] = roundPurchaseOf[_currentRound][_account].add(amount);

        // update the total amount purchased to the current round
        _rounds[_currentRound].totalDeposit = _rounds[_currentRound].totalDeposit.add(amount);

        // initialized buyer withdrawal for the first time the user buy tokens
        if(baseBuyersTotalTokenBalance[_account] == 0){
            for(uint256 i =0;i<vesting.length;i++){
                buyerWithdrawal[_account][i] = 1;
            }            
        }

        // update the total TOKEN expected balance of the buyer
        baseBuyersTotalTokenBalance[_account] = baseBuyersTotalTokenBalance[_account].add(tokenAmount);
        actualBuyersTotalTokenBalance[_account] = actualBuyersTotalTokenBalance[_account].add(tokenAmount);

        // update the current round TOKEN balance of user
        roundBalanceOf[_currentRound][_account] = roundBalanceOf[_currentRound][_account].add(tokenAmount); 

        
        // Deduct token balance to the current round token balance
        _deductTokenFromCurrentRoundTokenBalance(tokenAmount);

        if (_isInvestor == false) {
            if(paymentToken == address(0)){
                // transfer the BNB amount to the wallet specified
                (bool success, ) = receiverAddress.call{value: amount}("");
                require(success, "Failed to send BNB");
            } else {
                IERC20Upgradeable(paymentToken).safeTransferFrom(_account,  receiverAddress, amount);
            }
        }

        // Emit an event 
        emit TokensPurchased(_account, _tokenAddress, tokenAmount, _rounds[_currentRound].rate, amount);
    }

    function getRoundPurchaseOf(uint256 round, address user) external view returns (uint256){
        return roundPurchaseOf[round][user];
    }

    function _deductTokenFromCurrentRoundTokenBalance(uint256 amount ) private {

        // Require that Current round has enough tokens
      uint256 currentRoundTokenBalance = _rounds[_currentRound].tokenBalance;
      require(currentRoundTokenBalance >= amount,"Current round token balance is not enough to fulfill the purchase");
        
      unchecked {
          _rounds[_currentRound].tokenBalance = currentRoundTokenBalance.sub(amount);
      }
    }

    function currentRound() public view returns (uint) {
        return _currentRound;
    }

    function rounds(uint roundNumber) public view returns (Round memory) {
        return _rounds[roundNumber];
    }

    function tokenAddress() public view returns (address) {
        return _tokenAddress;
    }

    function getEnableWithdrawalFor(uint256 period) public view returns (bool) {
        return vestingEnabled[period] == ENABLED;
    }

    function setTokenAddress(address _token) public onlyOwner {
        _tokenAddress = _token;
    }

    function startRound() public onlyOwner {
        require(isPrivateSaleClosed == false, "Private Sale is closed");

        require(_rounds[_currentRound].open == false, "Current round is already open");

        _rounds[_currentRound].open = true;
    }

    function closePrivateSale() public onlyOwner {
        require(_currentRound == 1, "Current round is not round 1");
        require(_rounds[_currentRound].open == true, "Current round 1 is already closed");
        // check if soft cap already met
        require(_rounds[_currentRound].totalDeposit >= _rounds[_currentRound].totalSoftCap, "Round 1 softcap not met");

        _rounds[_currentRound].open = false;

        isPrivateSaleClosed = true;
    }

    function isPrivateSaleAlreadyClosed() public view returns (bool) {
        return isPrivateSaleClosed;
    }

    function getRoundBalanceOf(address _buyer, uint _roundNumber) public view  returns (uint256) {
        require(_roundNumber>=1 && _roundNumber <= 1, "Round should be greater than or equal to 1");
        return roundBalanceOf[_roundNumber][_buyer];
    }

    function getTotalBuyerExpectedToken(address _buyer) public view returns (uint256) {
        return actualBuyersTotalTokenBalance[_buyer];
    }

    function setEnableWithdrawalFor(uint256 period) public onlyOwner {
        require(isPrivateSaleClosed == true, "Private sale is currently open");

        require(period >= 0 && period <=8,"Invalid period");

        if(period > 0){
            require(vestingEnabled[period.sub(1)]==ENABLED,"Previous vesting period should be enabled");
        }
        vestingEnabled[period] = ENABLED;

        totalEnabledWithdrawal=totalEnabledWithdrawal.add(1);
    }

    function _getValue(uint256 rate, address account) private view returns (uint256) {
        uint256 actualTotalBuyerTokens = baseBuyersTotalTokenBalance[account];
        uint256 val = actualTotalBuyerTokens .mul(rate);
        val = val.div(100);
        return val;
    }
    function isUserHasPendingWithdrawal(address user) private view returns (bool){
        // buyerWithdrawal[_msgSender()].withdrawnPublicLaunch == Enable.NO || 
        // buyerWithdrawal[_msgSender()].withdrawnGameLaunch == Enable.NO || 
        // buyerWithdrawal[_msgSender()].withdrawnQuarter == Enable.NO
        bool hasPending = false;
        for(uint256 i =0;i<vesting.length;i++){
            if(buyerWithdrawal[user][i]==NOT_ENABLED){
                hasPending = true;
            }
        }   
        return hasPending;
    }
    

    function withdrawToken()  public whenNotPaused {
        require(_tokenAddress != address(0), "Token Address not set");

        uint256 currentTokenBalance = actualBuyersTotalTokenBalance[_msgSender()];
        // current total tokens should be greater than zero
        require(currentTokenBalance > 0,"Total withdrawable tokens should be greater than zero");
        
        // it should atleast one withdrawal is enabled
        require(totalEnabledWithdrawal > 0,"No Available for withdrawal");

        // it should atleast one is not withdrawn by the user
        bool hasPendingWithdrawal = isUserHasPendingWithdrawal(_msgSender());

        require(hasPendingWithdrawal,"Aldready withdrawn total tokens");

        // uint256 totalWithdrawableTokens = getUserTotalWithdrawableTokens(_msgSender())
        address user = _msgSender();
        uint256 totalWithdrawableTokens = 0;
        for(uint256 i =0;i<vesting.length;i++){
            if(vestingEnabled[i]==ENABLED && buyerWithdrawal[user][i] == NOT_ENABLED){
                // update the user set to already withdrawn
                buyerWithdrawal[user][i] = ENABLED;

                uint256 val = _getValue(vesting[i], user);

                // at the end
                if(i == vesting.length - 1){
                    val = currentTokenBalance > val ? currentTokenBalance : val;
                }

                totalWithdrawableTokens = totalWithdrawableTokens.add(val);
            }
        }

        // if(enableWithdrawalForPublicLaunch == Enable.YES && buyerWithdrawal[_msgSender()].withdrawnPublicLaunch == Enable.NO){
        //     buyerWithdrawal[_msgSender()].withdrawnPublicLaunch = Enable.YES;
        //     uint256 val = _getValue(30, _msgSender());

        //     totalWithdrawableTokens = totalWithdrawableTokens.add(val);
        // }

        // if(enableWithdrawalForGameLaunch == Enable.YES && buyerWithdrawal[_msgSender()].withdrawnGameLaunch == Enable.NO){
        //     buyerWithdrawal[_msgSender()].withdrawnGameLaunch = Enable.YES;
        //     uint256 val = _getValue(30, _msgSender());

        //     totalWithdrawableTokens = totalWithdrawableTokens.add(val);
        // }

        // if(enableWithdrawalForQuarter == Enable.YES && buyerWithdrawal[_msgSender()].withdrawnQuarter == Enable.NO){
        //     buyerWithdrawal[_msgSender()].withdrawnQuarter = Enable.YES;
        //     uint256 val = _getValue(40, _msgSender());

        //     val = currentTokenBalance > val ? currentTokenBalance : val;

        //     totalWithdrawableTokens = totalWithdrawableTokens.add(val);
        // }

        require(totalWithdrawableTokens > 0,"No withdrawable tokens");

        require(actualBuyersTotalTokenBalance[_msgSender()] >= totalWithdrawableTokens, "Total withdrawable tokens is not enough");
        
        actualBuyersTotalTokenBalance[_msgSender()] = actualBuyersTotalTokenBalance[_msgSender()].sub(totalWithdrawableTokens);

        // used for checking if this contract token balance has enough balance
        uint256 _contractBalance = IERC20Upgradeable(_tokenAddress).balanceOf(address(this));
        require(_contractBalance>=totalWithdrawableTokens,"Total withdrawable token is greater than contract token balance");

        // transfer the withdrawable tokens to the user
        bool _sent = IERC20Upgradeable(_tokenAddress).transfer(_msgSender(), totalWithdrawableTokens);

        // the withdrawable should sent
        require(_sent, "Failed to withdraw token");

        // emit an event that a user withdraw
        emit Withdraw(address(this), _msgSender(), totalWithdrawableTokens);
    }

    function getWithdrawableToken() public view returns (uint256) {
        address user = _msgSender();
        uint256 currentTokenBalance = actualBuyersTotalTokenBalance[user];

        uint256 totalWithdrawableTokens = 0; 

        for(uint256 i =0;i<vesting.length;i++){
            if(vestingEnabled[i]==ENABLED  && buyerWithdrawal[user][i] == NOT_ENABLED ){

                uint256 val = _getValue(vesting[i], user);

                // at the end
                if(i == vesting.length - 1){
                    val = currentTokenBalance > val ? currentTokenBalance : val;
                }

                totalWithdrawableTokens = totalWithdrawableTokens.add(val);
            }
        }

        // if(enableWithdrawalForPublicLaunch == Enable.YES && buyerWithdrawal[_msgSender()].withdrawnPublicLaunch  == Enable.NO){            
        //     uint256 val = _getValue(30, _msgSender());

        //     totalWithdrawableTokens = totalWithdrawableTokens.add(val);
        // }

        // if(enableWithdrawalForGameLaunch == Enable.YES && buyerWithdrawal[_msgSender()].withdrawnGameLaunch  == Enable.NO){            
        //     uint256 val = _getValue(30, _msgSender());

        //     totalWithdrawableTokens = totalWithdrawableTokens.add(val);
        // }

        // if(enableWithdrawalForQuarter == Enable.YES && buyerWithdrawal[_msgSender()].withdrawnQuarter  == Enable.NO){
        //     uint256 val = _getValue(40, _msgSender());

        //     val = currentTokenBalance > val ? currentTokenBalance : val;

        //     totalWithdrawableTokens = totalWithdrawableTokens.add(val);
        // }

        return totalWithdrawableTokens;
    }

     // white list
     function updateWhiteListForCurrentRound(address account, bool _isWhiteListed, uint roundNumber) public onlyOwner {
        require(roundNumber >= 1 && roundNumber <=1, "Round number 1  only");
        require(roundWhiteListed[roundNumber][account] != _isWhiteListed, "Account is already the value of 'white listed'");
        roundWhiteListed[roundNumber][account] = _isWhiteListed;

        emit UpdatedWhiteList(account, _isWhiteListed,roundNumber);
    }

    function updateWhiteListMultipleAccountsForCurrentRound(address[] calldata accounts, bool _isWhiteListed, uint roundNumber) public onlyOwner {
        require(roundNumber >= 1 && roundNumber <=1, "Round number 1 only");
        for(uint256 i = 0; i < accounts.length; i++) {
            roundWhiteListed[roundNumber][accounts[i]] = _isWhiteListed;
        }

        emit UpdateWhiteListMultipleAccounts(accounts, _isWhiteListed , roundNumber);
    }

    function isWhiteListed(address account, uint roundNumber) public view returns(bool) {
        require(roundNumber >= 1 && roundNumber <=1, "Round number 1  only");
        return roundWhiteListed[roundNumber][account];
    }

    // emergency withdraw of tokens in case theres an issue occur
    function emergencyWithdraw()
    public onlyOwner
    whenPaused
    {

        require(_tokenAddress != address(0), "Token Address not set");
        
        uint256 balance = IERC20Upgradeable(_tokenAddress).balanceOf(address(this));
        IERC20Upgradeable(_tokenAddress).transfer(owner(), balance);
    }
    

    function updatePauseContract() public onlyOwner {
        bool isPaused = paused();
        if(isPaused) {
            _unpause();
        } else {
            _pause();
        }
    }

    function updateInvestorsMultipleAccounts(address[] calldata accounts, bool _isInvestor) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _investors[accounts[i]] = _isInvestor;
        }
    }

    function isInvestor(address account) public view returns(bool) {
        return _investors[account];
    }

    function getBuyerWithdrawal(address account, uint256 period ) public view returns (uint256) {
        return buyerWithdrawal[account][period];
    }
}