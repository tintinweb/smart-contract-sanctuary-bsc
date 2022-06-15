/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PresaleTest {
    IERC20 public token;
    uint public min_amount;
    mapping (address => uint256) balance;
    mapping (address => uint256) claimed;
    mapping (address => uint256) bnb_pay;
    mapping (address => bool) authorized;
    bool presale_status = true;
    bool claim_status = false;
    bool payback_status = false;
    uint start_time;
    uint256 public total_raised = 0;
    uint256 public final_raised = 0;
    uint256 public final_tokens = 0;

    constructor(
        address _token,
        uint _starttm,
        uint _minamo
        ) public {
            token = IERC20(_token);
            start_time = _starttm;
            min_amount = _minamo;
            authorized[msg.sender]=true;
        }

        modifier onlyAuthorized() {
            require(authorized[msg.sender] == true); _;
        }

        function contribute() public payable {
          require(msg.value >= min_amount, "Insufficient amount");
          require(presale_status == true, "Presale closed");
          require(block.timestamp >= start_time, "Presale not started yet");

          uint add_balance = balance[msg.sender] + msg.value;
          balance[msg.sender]=add_balance;
          bnb_pay[msg.sender]=bnb_pay[msg.sender] + msg.value;
          total_raised=total_raised + msg.value;
        }

        function contractTokenBalance() public view returns (uint256) {
             return token.balanceOf(address(this));
        }

        function availableTokensAmount() public view returns (uint256) {
               uint256 availableTokens = presale_status ? contractTokenBalance() : final_tokens;
               return availableTokens;
        }

        function availableBnbAmount() public view returns (uint256) {
             uint256 availableBnb = presale_status ? total_raised : final_raised;
               return availableBnb;
        }

        function calculatePerBnb() public view returns (uint256) {
             uint256 totalTokens = availableTokensAmount();
             uint256 totalBnb = availableBnbAmount();
             return totalTokens / ( totalBnb !=0 ? totalBnb : 1);
        }

        function calculateClaimAmount(uint256 bnbAmount) public view returns (uint256) {
               uint256 perBnb = calculatePerBnb();
               uint256 claimableTokensAmount = bnbAmount * perBnb;

               return claimableTokensAmount;
        }

        function claimToken() public returns (bool) {
          require(balance[msg.sender] >= 10, "Insufficient balance");
          require(claim_status == true, "Presale not ended yet");

          uint256 claimableTokensAmount = calculateClaimAmount(balance[msg.sender]);

          _safeTransfer(token, msg.sender, claimableTokensAmount);

          balance[msg.sender]=0;
          return true;
        }

        function payback() public returns (bool) {
          require(bnb_pay[msg.sender] >= 10, "Insufficient balance");
          require(payback_status == true, "Not payback balance");

          address payable contributer = payable(msg.sender);

          contributer.transfer(bnb_pay[msg.sender]);

          claimed[msg.sender]=bnb_pay[msg.sender];
          bnb_pay[msg.sender]=0;

          return true;
        }

        function _safeTransfer(IERC20 tokencontract, address recipient, uint amount) private {bool sent = tokencontract.transfer(recipient, amount);
            require(sent, "Token transfer failed");
        }

        function transfercBNB(uint256 amount, address receiveAddress) external onlyAuthorized() {
            payable(receiveAddress).transfer(amount);
        }

        function showBalance(address contributer) public view returns (uint) {
             return balance[contributer];
        }

        function showPayment(address contributer) public view returns (uint) {
             return bnb_pay[contributer];
        }

        function showClaimed(address contributer) public view returns (uint) {
             return claimed[contributer];
        }

        function showRaised() public view returns (uint256) {
             return total_raised;
        }

        function transfercTOKEN(IERC20 tokenc, address receiveAddress, uint256 amount) external onlyAuthorized() {
            _safeTransfer(tokenc, receiveAddress, amount);
        }

        function setClaimStatus(bool _claimst) public onlyAuthorized() {
             claim_status = _claimst;
             if(_claimst){
                    setPresaleStatus(false);
                    final_raised = total_raised;
                    final_tokens = contractTokenBalance();
             }
        }

        function setPresaleStatus(bool _prslst) public onlyAuthorized() {
             presale_status = _prslst;
             if(_prslst){
                    setClaimStatus(false);
             }
        }

        function setPaybackStatus(bool _pybksts) public onlyAuthorized() {
             payback_status = _pybksts;
        }

        function setStartTime(uint _strttm) public onlyAuthorized() {
             start_time = _strttm;
        }

        function setMinAmount(uint _amount) public onlyAuthorized() {
             min_amount = _amount;
        }

        function setTokenAddress(address _token) external onlyAuthorized() {
             require(address(token) != _token, "You didn't change token address.");
             token = IERC20(_token);
        }

        function updateAuthorized(address _wallet, bool _flag) external onlyAuthorized() {
             require(authorized[_wallet] != _flag, "You didn't change ownership.");
             authorized[_wallet] = _flag;
        }
}