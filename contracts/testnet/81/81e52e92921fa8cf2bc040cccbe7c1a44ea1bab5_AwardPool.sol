/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function mint(address account, uint amount) external;
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}



contract AwardPool {
    using SafeMath for uint256;



    mapping(address => address) public userInfo;

	

	IERC20 public MGF = IERC20(0xab41A7cd610f8173aE8F281A5740822f96855137);
	IERC20 public MGFA = IERC20(0x265a8c035158f2a397c2EAF4c996f5c7FD64deF4);
	

	
	address public burnAddress = 0x000000000000000000000000000000000000dEaD;
	uint256 public burnRate = 60;
	
    address public foundationWallet = 0xb54c9dC6e319fed95DBD3e78685E88E43E476e8e;
	uint256 public foundationRate = 20;
	
	address public technologyAddress = 0xb54c9dC6e319fed95DBD3e78685E88E43E476e8e;
	uint256 public technologyRate = 10;
	
	address public mediaAddress = 0xb54c9dC6e319fed95DBD3e78685E88E43E476e8e;
	uint256 public mediaRate = 5;
	
	address public activityAddress = 0xb54c9dC6e319fed95DBD3e78685E88E43E476e8e;
	uint256 public activityRate = 5;

    address public owner;


    
    event Deposit(address indexed user, uint256 amount);


    constructor() public {
        owner = msg.sender;


    }
	


    function pledge(uint256 _amount, address _leader) public { 


        MGF.transferFrom(msg.sender,burnAddress,getAmount(_amount,burnRate));
        MGF.transferFrom(msg.sender,foundationWallet,getAmount(_amount,foundationRate));
        MGF.transferFrom(msg.sender,technologyAddress,getAmount(_amount,technologyRate));
        MGF.transferFrom(msg.sender,mediaAddress,getAmount(_amount,mediaRate));
		MGF.transferFrom(msg.sender,activityAddress,getAmount(_amount,activityRate));
        
		userInfo[msg.sender] = _leader;
        emit Deposit(msg.sender, _amount);
		
	
    }

    
    function getAmount(uint256 _amount, uint256 _rate) internal pure returns(uint256){
        return _amount.mul(_rate).div(100);
    }



    
	
	function setWallet(address _burnAddress,
						uint256 _burnRate,
						address _foundationWallet,
						uint256 _foundationRate,
						address _technologyAddress,
						uint256 _technologyRate,
						address _mediaAddress,
						uint256 _mediaRate,
						address _activityAddress,
						uint256 _activityRate)public onlyOwner {
		
		burnAddress = _burnAddress;
		burnRate =  _burnRate;
		foundationWallet = _foundationWallet;
		foundationRate = _foundationRate;
		technologyAddress = _technologyAddress;
		technologyRate = _technologyRate;
		mediaAddress = _mediaAddress;
		mediaRate = _mediaRate;
		activityAddress = _activityAddress;
		activityRate = _activityRate;
	}
    

    function withdrawStuckTokens(address _token, uint256 _amount) public onlyOwner {
		IERC20(_token).transfer(msg.sender, _amount);
	}
	
	function PayTransfer(address payable recipient) public onlyOwner {
		recipient.transfer(address(this).balance);
	}

    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
}