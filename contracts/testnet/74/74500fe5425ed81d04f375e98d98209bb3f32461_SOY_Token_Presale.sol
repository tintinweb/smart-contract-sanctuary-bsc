/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

contract SOY_Token_Presale is Ownable {

    IERC20 SOYToken;

    uint256 private _tokenDecimal = 18;
    uint256 private _PresaleToken = 100_000_000 * (10 ** _tokenDecimal);
    uint256 public _SoldOut;
    bool public paused;

    uint256 PhaseOne = 85000000000000; //(100M to 75M) SOY = 0.000085 BNB
    uint256 PhaseTwo = 102000000000000; //(75M to 25M) 1 SOY = 0.000102 BNB
    uint256 PhaseThree = 122400000000000; //(<25M) 1 SOY = 0.0001224 BNB

    uint256 PhaseOneLimit = 75_000_000 * (10 ** _tokenDecimal);
    uint256 PhaseTwoLimit = 25_000_000 * (10 ** _tokenDecimal);

    constructor(address _token) {
        SOYToken = IERC20(_token);
    }

    function joinPresale(address _ref) public payable {

        uint contractBalance = getBalance();
        bool transferRef;
        uint PhaseChecker;
        uint EstimatedToken;

        require(contractBalance != 0,"Contract Balance is Low!!");
        require(!paused,"Presale is Currently Paused!!");

        //  -- Phase Detection --

        if (contractBalance > PhaseOneLimit) {
            require(msg.value >= PhaseOne,"-> 1 SOY = 0.00085 BNB!!");
            PhaseChecker = 1;
        }
        else if (contractBalance > PhaseTwoLimit) {
            require(msg.value >= PhaseTwo,"-> 1 SOY = 0.000102 BNB!!");
            PhaseChecker = 2;
        }
        else {
            require(msg.value > PhaseThree,"-> 1 SOY = 0.0001224 BNB!!");
            PhaseChecker = 3;
        }

        //  -- Referral --

        if(_ref == msg.sender || _ref == address(0x0)) {
            transferRef = false;
        }
        else {
            if(SOYToken.balanceOf(_ref) > 0) {
                transferRef = true;
            }
            else {
                transferRef = false;
            }
        }

        uint256 value = msg.value;

        if(transferRef) {
            uint TenPercent = value * (10) / 100;
            payable(_ref).transfer(TenPercent);
        }

        if(PhaseChecker == 1) {
            EstimatedToken = value * (10 ** _tokenDecimal) / PhaseOne;
        }

        if(PhaseChecker == 2) {
            EstimatedToken = value * (10 ** _tokenDecimal) / PhaseTwo;
        }

        if(PhaseChecker == 3) {
            EstimatedToken = value * (10 ** _tokenDecimal) / PhaseThree;
        }

        if(EstimatedToken > 0) {
            SOYToken.transfer(msg.sender,EstimatedToken);
            _SoldOut += EstimatedToken;
        }
        else {
            revert("Error: Something went wrong!!");
        }

    }

    function setPause(bool _status) public onlyOwner {
        paused = _status;
    }

    function getBalance() public view returns (uint) {
        return SOYToken.balanceOf(address(this));
    }

    function withdrawFunds() public onlyOwner {
        (bool os,) = payable(msg.sender).call{value: address(this).balance}("");
        require(os,"Transaction Failed!!");
    }
	
	function rescueToken() public onlyOwner {
		SOYToken.transfer(msg.sender,SOYToken.balanceOf(address(this)));
	}



}