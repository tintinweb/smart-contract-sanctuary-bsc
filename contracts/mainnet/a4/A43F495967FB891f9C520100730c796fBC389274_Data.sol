/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

    library SafeMath {//konwnsec//IERC20 接口
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
                return 0; 
            }
            uint256 c = a * b;
            assert(c / a == b);
            return c; 
        }
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
// assert(b > 0); // Solidity automatically throws when dividing by 0
            uint256 c = a / b;
// assert(a == b * c + a % b); // There is no case in which this doesn't hold
            return c; 
        }
        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            assert(b <= a);
            return a - b; 
        }

        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            assert(c >= a);
            return c; 
        }


    }

    interface Erc20Token {//konwnsec//ERC20 接口
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }
    
    contract Base {
        using SafeMath for uint;
        Erc20Token public MCN   = Erc20Token(0x3a5b49CC36BE1Ed01F59558B7cA4Ec47BF6CdFb1);
 
        uint256 public _startTime;
        address public zyaddress;
        address public _owner ;
        address public owManager;

        function Convert18(uint256 value) internal pure returns(uint256) {
            return value.mul(1000000000000000000);
        }
   
  
        modifier onlyOwner() {
            require(msg.sender == _owner, "_owner Permission denied"); _;
        }


        modifier onlyowManager() {
            require(msg.sender == owManager, "Manager Permission denied"); _;
        }
        modifier isZeroAddr(address addr) {
            require(addr != address(0), "Cannot be a zero address"); _; 
        }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

      function transferowManagership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owManager = newOwner;
    }
    receive() external payable {}  
}
contract Data is Base{
    uint256 public oneDay = 86400; 



        constructor()
  public {
        _owner = msg.sender; 
       

     }
    function transferMCN() public onlyowManager {
        require(block.timestamp.sub(_startTime)>=oneDay);
        MCN.transfer(zyaddress,Convert18(10000));
        _startTime = block.timestamp; 
    }


     function setZYAddress(address newaddress) public onlyowManager {
        require(newaddress != address(0));
        zyaddress = newaddress;
    }

}