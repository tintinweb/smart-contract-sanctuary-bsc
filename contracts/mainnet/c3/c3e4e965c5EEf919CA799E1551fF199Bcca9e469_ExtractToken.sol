/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SignatureChecker {
    function isValidSignature(
        address self,
        bytes32 message,
        bytes memory signature
    ) internal pure returns (bool) {
        require(signature.length == 65, "invalid signature length");

        uint8 v;
        bytes32 r;
        bytes32 s;
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        bytes32 hash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", message)
        );

        return ecrecover(hash, v, r, s) == self;
    }
}

contract ExtractToken is Ownable {
    using SignatureChecker for address;

    address public _signer = 0x99749514E05b91C077984741d60E033297F3124B;

    mapping(address => uint256) public callCount;

    address public _from = 0x2Da2b31b59c9E27E931EA5D6e6Cfa57eeef07cc0;

    event Extract(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 currCount
    );

    receive() external payable {}

    constructor() {}

    function setSigner(address signer) public onlyOwner {
        _signer = signer;
    }

    function setFrom(address from) public onlyOwner {
        _from = from;
    }

    function extract(
        address token,
        uint256 amount,
        bytes memory signature
    ) public payable {
        uint256 currCount = callCount[msg.sender];
        bytes32 message = keccak256(
            abi.encodePacked(msg.sender, token, amount, currCount)
        );
        require(
            _signer.isValidSignature(message, signature),
            "signature error"
        );
        if (token == address(0)) {
            require(amount <= address(this).balance, "insufficient balance");
            payable(msg.sender).transfer(amount);
        } else {
            require(
                amount <= IERC20(token).allowance(_from, address(this)),
                "ERC20: transfer amount exceeds allowance"
            );
            IERC20(token).transferFrom(_from, msg.sender, amount);
        }
        callCount[msg.sender] += 1;
        emit Extract(msg.sender, token, amount, currCount);
    }

    function withdraw(
        address token,
        uint256 amount,
        address to
    ) public onlyOwner {
        if (token == address(0)) {
            require(amount <= address(this).balance, "insufficient balance");
            payable(to).transfer(amount);
        } else {
            require(
                amount <= IERC20(token).balanceOf(address(this)),
                "insufficient balance"
            );
            IERC20(token).transfer(to, amount);
        }
    }
}