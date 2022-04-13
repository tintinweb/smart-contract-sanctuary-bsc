/**
 *Submitted for verification at BscScan.com on 2022-04-13
*/

// contracts/TokenForwarder.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
  
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract BlackList is Ownable {
    function getBlackListStatus(address _maker) external view returns (bool) {
        return isBlackListed[_maker];
    }

    mapping (address => bool) public isBlackListed;
    
    function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        RemovedBlackList(_clearedUser);
    }

    event AddedBlackList(address _user);

    event RemovedBlackList(address _user);
}

contract TokenForwarder is Ownable, BlackList {
    bool public activeStatus = true;
    address public parentAddress;
   
	event Payment(address from, address to, address tokenContractAddress, uint256 amount, uint256 orderId);
    event Forward(address from, address to, uint256 amount, uint256 orderId);
    event Received(address from, uint256 amount);

	constructor() public {
        parentAddress = msg.sender;
    }

    function setActiveStatus(bool _status) public onlyOwner {
        activeStatus = _status;
    }

    function changeParent(address newParentAddress) public onlyOwner {
        parentAddress = newParentAddress;
    }

    receive() external payable {
        require( activeStatus , "Not allowed" );
        require( !isBlackListed[msg.sender] );

        payable(parentAddress).transfer(msg.value);
        emit Received(msg.sender, msg.value);
    }

    function forward(address to, uint256 _orderId) payable public {
        require( activeStatus , "Not allowed" );
        require( msg.value > 0, "Invalid amount" );
        require( _orderId > 0, "Invalid orderId" );
        require( !isBlackListed[msg.sender], "Not allowed" );
        require( !isBlackListed[to], "Not allowed" );

        payable(to).transfer(msg.value);
        emit Forward(msg.sender, to, msg.value , _orderId);
    }
      
    function payment(address to, address tokenContractAddress, uint256 _amount, uint256 _orderId) public {
        require( activeStatus, "Not allowed" );
        require( _amount > 0, "Invalid amount" );
        require( _orderId > 0, "Invalid orderId" );
        require( !isBlackListed[msg.sender], "Not allowed" );
        require( !isBlackListed[to], "Not allowed" );
        require( !isBlackListed[tokenContractAddress], "Not allowed" );
		
		IERC20 instance = IERC20(tokenContractAddress);
        uint256 forwardBalance = instance.balanceOf(address(msg.sender));
        if (forwardBalance < _amount) {
            revert();
        }
        if (!instance.transferFrom(address(msg.sender), to, _amount)) {
            revert();
        }
        emit Payment(msg.sender, to, tokenContractAddress, _amount, _orderId);
    } 
}