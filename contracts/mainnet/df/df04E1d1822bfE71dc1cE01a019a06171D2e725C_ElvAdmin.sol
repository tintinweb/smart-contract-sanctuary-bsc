/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

pragma solidity >=0.4.2 <0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender)external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
}
contract ElvAdmin{
    address public _owner;
    uint[] public _timestampList;
    uint public _number;
    address public _token;
    constructor(address _adminAddress,address token,uint[] memory timestamp) public {
      _owner = _adminAddress;
      _timestampList = timestamp;
      _number = 500000*10**8;
      _token = token;
    }
    struct Pledgor{
        uint amount;
    }
    Pledgor[] public pledgor;
    mapping(address => Pledgor) public pledgors;
    function reward() public {
        require(msg.sender == _owner, "No way to extract");
        uint _timestamps = now;
        uint flag = 0;
        for (uint i = 0;i < _timestampList.length;i++){
            if (_timestampList[i] < _timestamps){
                flag += 1;
            }
        }
        uint amount = flag * _number;
        uint userAmount = amount - pledgors[msg.sender].amount;
        IERC20(_token).transfer(msg.sender,userAmount);
        pledgors[msg.sender].amount += userAmount;
    }
    function rewardReturn() public view returns(uint){
        uint _timestamps = now;
        uint flag = 0;
        for (uint i = 0;i < _timestampList.length;i++){
            if (_timestampList[i] < _timestamps){
                flag += 1;
            }
        }
        uint amount = flag * _number;
        uint userAmount = amount - pledgors[msg.sender].amount;
        return userAmount;
    }
  }