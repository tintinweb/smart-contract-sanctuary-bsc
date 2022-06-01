// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./ERC20.sol";
import "./SafeMathInt.sol";
import "./DividendPayingToken.sol";


contract DividendTracker is Ownable,DividendPayingToken,ReentrancyGuard{
    using SafeMath for uint256;
    using SafeMathInt for int256;

    //
    mapping (address => bool) public excludedFromDividends;  //不分红集合
    //
    uint256 public minimumTokenBalanceForDividends;  //最低持币数量分红


    address[] private _dividendUsers; // All users address who has deposited.
    mapping(address => bool) private _dividendUserAdded; // All users address who has deposited.


    mapping(address => bool) public operators;
    modifier onlyOperator() {
        require(operators[msg.sender], "Operator: caller is not the operator");
        _;
    }

    //
    event ExcludeFromDividends(address indexed account);

    constructor()  DividendPayingToken("TB_Dividen_Tracker", "TB_Dividend_Tracker") {

        minimumTokenBalanceForDividends = 100*10000*10000 * (10**18); //must hold tokens

        operators[msg.sender] = true;
    }

    function setOperator(address _operator, bool _enabled) public onlyOwner {
        operators[_operator] = _enabled;
    }

    function _transfer(address, address, uint256) internal override {
        require(false, "TB_Dividend_Tracker: No transfers allowed");
        super._transfer(address(0),address(0),0);
    }

    //设置TB持币量达标多少才能分红TRX
    function setMinimumTokenBalanceForDividends(uint256 _minimumTokenBalanceForDividends) external onlyOperator{
        minimumTokenBalanceForDividends = _minimumTokenBalanceForDividends;
    }

    

    function distributeDividends(uint256 amount) public override onlyOperator {
       super.distributeDividends(amount);
    }

    function withdrawEth(address to,uint256 amount) public override onlyOperator {
          super.withdrawEth(to,amount);
    }
    //领取
    function withdrawDividend() public override {
        address account = msg.sender;
        uint256 withdrawableDividends = withdrawableDividendOf(account);      
        if (withdrawableDividends > 0 && !_dividendUserAdded[account]) {
            _dividendUsers.push(account);
            _dividendUserAdded[account] = true;
        }

       super.withdrawDividend();
    }

    //分红的人数
    function getNumberDividendUsers() external view returns(uint256) {
        return _dividendUsers.length;
    }

    //设置不分红的地址
    function excludeFromDividends(address account) external onlyOperator {

        excludedFromDividends[account] = true;
        _setBalance(account, 0);

        emit ExcludeFromDividends(account);
    }

    function getAccount(address _account) public view returns (
        address account,
        uint256 withdrawableDividends,
        uint256 totalDividends) {

        account = _account;
        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);
    }


    function setBalance(address payable account, uint256 newBalance) external onlyOperator {
        if(excludedFromDividends[account]) {
            return;
        }

        if(_isContract(account)){
            return;
        }

        if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
        }
        else {
            _setBalance(account, 0);
        }

    }


    /**
    * @notice Returns true if `account` is a contract.
     * @param account: account address
     */
    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}