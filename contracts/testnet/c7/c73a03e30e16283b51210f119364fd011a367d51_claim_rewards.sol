/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


contract claim_rewards {
using SafeMath for uint256;

//uint256 _adabalance = 35742100000000000000;
//uint256 _totalsupply = 25000000000000000000000000;
//uint256 _balance = 309698851314572500000000;

address _adacontract = 0x3EE2200Efb3400fAbB9AacF31297cBdD1d435D47;

address public _owner;

struct claim {
        uint256 claimamount;
        uint256 claimed;
        uint256 timestamp;
        uint256 lastclaim;
        uint256 registered;
}

address[] addresstracking;
mapping(address => uint256) internal addressmapping;
mapping(address => claim) public claimedamounts;



  constructor(){
      _owner = msg.sender;
  
  }



function updatewallets(address[] memory recipients, uint256[] memory  values)  external onlyOwner   {
      for (uint256 i = 0; i < recipients.length; i++) {
        address walletaddress = recipients[i];
       addresstracking.push(walletaddress);
         claimedamounts[walletaddress].timestamp = block.timestamp;
         claimedamounts[walletaddress].registered = 1;
         claimedamounts[walletaddress].claimamount = values[i];
      }
    }





function addaddress(address _address) internal {
if (addressmapping[_address] == 0) {
    addressmapping[_address] = 1;
    addresstracking.push(_address);
  }
 }




 modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: only owner can call this function");
        // This _; is not a TYPO, It is important for the compiler;
        _;
    }


    /**
    * @notice owner() returns the currently assigned owner of the Token
    * 
     */
    function owner() public view returns(address) {
        return _owner;

    }
    /**
    * @notice renounceOwnership will set the owner to zero address
    * This will make the contract owner less, It will make ALL functions with
    * onlyOwner no longer callable.
    * There is no way of restoring the owner
     */
    function renounceOwnership() public onlyOwner {
      
        _owner = address(0);
    }

    /**
    * @notice transferOwnership will assign the {newOwner} as owner
    *
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    /**
    * @notice _transferOwnership will assign the {newOwner} as owner
    *
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
       
        _owner = newOwner;
    }



////////////////////////////

function registeraddress() public  {
  addaddress(msg.sender);
  claimedamounts[msg.sender].timestamp = block.timestamp;
  claimedamounts[msg.sender].registered = 1;
}

//uint256 _adabalance = mold_contract(address(_adacontract)).balanceOf(0xf437F8aCf706dE60362D50AaC76bD7698a52CF4a);
//uint256 _totalsupply = mold_contract(address(0x8B7F23A2184C94940e678950013c5bf15CC09626)).totalSupply();
//uint256 _balance = mold_contract(0x8B7F23A2184C94940e678950013c5bf15CC09626).balanceOf(msg.sender);
//uint256 percentage = _balance * 1000000000000000000 / _totalsupply *100 ;
//uint256 allownace = _adabalance /100* percentage ;
//return allownace/1000000000000000000;


function checkclaim() public view returns  (uint256) {
   return claimedamounts[msg.sender].claimamount -  claimedamounts[msg.sender].claimed;
}


function makeclaim() public returns (uint256){
uint256 _allowance = claimedamounts[msg.sender].claimamount;
claimedamounts[msg.sender].lastclaim = block.timestamp;
IERC20 busd = IERC20(address(0x3EE2200Efb3400fAbB9AacF31297cBdD1d435D47));
// transfers ada that belong to your contract to the specified address
busd.approve(address(this), _allowance); // We give permission to this contract to spend the sender tokens
busd.transferFrom(address(this), msg.sender, _allowance);
return _allowance;
}



function updateadabalance(uint256 _amount) public onlyOwner {

uint256 _totalsupply = IERC20(address(0x8B7F23A2184C94940e678950013c5bf15CC09626)).totalSupply();

for (uint256 s = 0; s < addresstracking.length; s += 1){

uint256 _balance = IERC20(0x8B7F23A2184C94940e678950013c5bf15CC09626).balanceOf(addresstracking[s]);
uint256 percentage = _balance * 1000000000000000000 / _totalsupply *100 ;
uint256 _allowance = _amount /100* percentage ; /// work out what their allownance is from the new ada balanace.
_allowance = _allowance/1000000000000000000;

claimedamounts[addresstracking[s]].claimamount = claimedamounts[addresstracking[s]].claimamount + _allowance; // add new alloenance to claim array
claimedamounts[addresstracking[s]].timestamp = block.timestamp;
}
}







function vesting(uint _a, uint _b, uint _precision)  internal pure returns  ( uint) {
     return (_a *(10**_precision) / _b  )*100;
}

function percentageAmount(uint256 total_, uint percentage_) internal pure returns (uint256 percentAmount_) {
        return div(mul(total_, percentage_), 1000);
}


//safemaths functions
 function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint a, uint b) internal pure returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }
  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }
  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }
  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }
  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

   function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = add(a,m);
        uint256 d = sub(c,1);
        return mul(div(d,m),m);
    }

  uint value;
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


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