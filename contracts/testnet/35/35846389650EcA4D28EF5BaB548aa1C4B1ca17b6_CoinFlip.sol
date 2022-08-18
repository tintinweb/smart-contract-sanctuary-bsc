/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

pragma solidity 0.5.10;

contract CoinFlip {

constructor () public{
       Owner = msg.sender;
   }

    event GameResult(uint result);

    using SafeMath for uint256;
    uint public Flips;
    uint public Wins;
    uint public Loses;
    uint256 public totalInvested;

    uint256 public INVEST_MIN_AMOUNT = 1e16; // 0.01 bnb
    uint256 public INVEST_MAX_AMOUNT = 5e16; // 0.01 bnb
    address Owner;

modifier onlyOwner() {
        require(msg.sender == Owner, 'Not owner');
        _;
    }    

    function withdraw() public onlyOwner {
        msg.sender.transfer(address(this).balance); 
    }

function invest() public payable  returns (uint){
        uint dep = msg.value;
        uint prize = dep * 2;
        require(msg.value >= INVEST_MIN_AMOUNT, "fail min");

        uint _random=randomFunc();

        if(_random == 1){
            msg.sender.transfer(prize);
            Wins=Wins+1;
        } else{
            Loses=Loses+1;
        }
        Flips=Flips+1;
        totalInvested = totalInvested.add(msg.value);
            emit GameResult(_random);
       return _random;
    }

    function randomFunc() public view returns (uint){
        uint random_number = uint(block.number)%2;
        return random_number;
    }

    function getNumber() public view returns (uint){
        return block.number;
    }

    function getMaxInvest() public view returns (uint256) {
        return address(this).balance/100*10;
    }

}


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}