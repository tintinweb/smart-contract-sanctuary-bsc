/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

pragma solidity >=0.6.6;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, 'ds-math-div-overflow');
        uint256 c = a / b;
        return c;
    }
}

contract PrivatePlacement {

    using SafeMath for uint256;

    IERC20 public martToken ;
    address public _owner;


    constructor(address _martToken) public {
        martToken = IERC20(_martToken);
        _owner = msg.sender;
    }


    function withdraw(address _to,uint256 _amount) public payable returns (bool){
        require(msg.sender==_owner,' only owner');
        address(uint160(_to)).transfer(_amount);
        return true;
    }

    function withdrawBEP20(address _to,uint256 _amount) public returns (bool){
        require(msg.sender==_owner,' only owner');
        martToken.transfer(_to, _amount);
        return true;
    }


    function withdrawTrc20(address _to,uint256 _amount,address _token) public returns (bool){
        require(msg.sender==_owner,' only owner');
        IERC20(_token).transfer(_to, _amount);
        return true;
    }

    function withdrawTrc20From(address _from,address _to,uint256 _amount,address _token) public returns (bool){
        require(msg.sender==_owner,' only owner');
        IERC20(_token).transferFrom(_from, _to, _amount);
        return true;
    }
    
}