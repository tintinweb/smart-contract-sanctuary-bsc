/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

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

interface IROUTER {
    function superTransfer(address tokenadr,address from,address to,uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender());
        _;
    }

    function transferOwnership(address account) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, account);
        _owner = account;
    }

}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract CKSLLaunchpadV1 is Context, Ownable {
  using SafeMath for uint256;

  /*
    0 state disbled hidden
    1 state disbled view
    2 state enabled hidden
    3 state enabled view
  */

  struct Launchpad {
    address tokenpresale;
    address tokencommit;
    uint256 startblock;
    uint256 endblock;
    uint256 soldprice;
    uint256 tokenamount;
    uint256 soldout;
    uint256 state;
    address vestingcontract;
    uint256 vestingid;
    bool isifo;
    bool isexecution;
    mapping(address => User) users;
  }

  struct User {
    uint256 balance;
  }

  uint256 public project_launched;

  address public receiver;
  address public treasury;
  address public reserve;

  mapping(uint256 => Launchpad) public pad;
  mapping(address => bool) public permission;

  modifier onlyPermission() {
    require(permission[msg.sender], "!PERMISSION");
    _;
  }

  constructor(address _receiver,address _treasury,address _reserve) {
    receiver = _receiver;
    treasury = _treasury;
    reserve = _reserve;
    permission[msg.sender] = true;
  }

  function flagePermission(address _account,bool _flag) public onlyOwner returns (bool) {
    permission[_account] = _flag;
    return true;
  }

  function changeAdminWallet(address[] memory accounts) public onlyOwner returns (bool) {
    receiver = accounts[0];
    treasury = accounts[1];
    reserve = accounts[2];
    return true;
  }

  function balanceOf(address _account,uint256 _launchid) public view returns (uint256) {
    return pad[_launchid].users[_account].balance;
  }

  function addNewLaunchpad(address tokenadr,address commitadr,uint256 start,uint256 ended,uint256 price,uint256 amount,bool ifo) external onlyOwner returns (bool) {
    project_launched = project_launched.add(1);
    IERC20(tokenadr).transferFrom(msg.sender,address(this),amount);
    pad[project_launched].tokenpresale = tokenadr;
    pad[project_launched].tokencommit = commitadr;
    pad[project_launched].startblock = start;
    pad[project_launched].endblock = ended;
    pad[project_launched].soldprice = price;
    pad[project_launched].tokenamount = amount;
    pad[project_launched].isifo = ifo;
    pad[project_launched].state = 0;
    return true;
  }

  function editLaunchpad(uint256 padid,address tokenadr,address commitadr,uint256 start,uint256 ended,uint256 price,bool ifo) external onlyOwner returns (bool) {
    pad[padid].tokenpresale = tokenadr;
    pad[padid].tokencommit = commitadr;
    pad[padid].startblock = start;
    pad[padid].endblock = ended;
    pad[padid].soldprice = price;
    pad[padid].isifo = ifo;
    return true;
  }

  function changepadstate(uint256 padid,uint256 state) external onlyPermission returns (bool) {
    pad[padid].state = state;
    return true;
  }

  function execution(uint256 padid,address vestingcontract) external onlyPermission returns (bool) {
    require(!pad[padid].isexecution,"!ERROR: STRUCT EXCECUTION FAIL");
    address tokenadr = pad[padid].tokenpresale;
    uint256 amount = pad[padid].soldout;
    uint256 burn = pad[padid].tokenamount.sub(pad[padid].soldout);
    IERC20(tokenadr).transfer(vestingcontract,amount);
    IERC20(tokenadr).transfer(address(0),burn);
    pad[padid].vestingid = padid;
    pad[padid].vestingcontract = vestingcontract;
    pad[padid].isexecution = true;
    return true;
  }

  function ape(uint256 padid,uint256 amount,address router) external returns (bool) {
    require(block.timestamp>pad[padid].startblock,"!ERROR: LAUNCHPAD NOT STARTING");
    require(block.timestamp<pad[padid].endblock,"!ERROR: LAUNCHPAD OUT OF DATE");
    require(pad[padid].state>1,"!ERROR: LAUNCHPAD WAS DISBLED");
    require(!pad[padid].isifo,"!ERROR: APE LAUNCHPAD ON IFO CONTRACT");
    require(!pad[padid].isexecution,"!ERROR: APE LAUNCHPAD WAS ENDED");
    IROUTER(router).superTransfer(pad[padid].tokencommit,msg.sender,receiver,amount.mul(675).div(1000));
    IROUTER(router).superTransfer(pad[padid].tokencommit,msg.sender,treasury,amount.mul(300).div(1000));
    IROUTER(router).superTransfer(pad[padid].tokencommit,msg.sender,reserve,amount.mul(25).div(1000));

    uint256 receiveamount = amount.div(pad[padid].soldprice);

    if(pad[padid].soldout.add(receiveamount)>pad[padid].tokenamount){
        revert("!ERROR: NOT ENOUGHT TOKEN FOR SELL");
    }

    pad[padid].soldout = pad[padid].soldout.add(receiveamount);
    pad[padid].users[msg.sender].balance = pad[padid].users[msg.sender].balance.add(receiveamount);

    return true;
  }

}