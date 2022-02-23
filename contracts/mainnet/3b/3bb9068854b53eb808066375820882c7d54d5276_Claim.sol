/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.10;

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

contract Claim {
    uint256 public ethfee;
    address public signer;
    address public receiv;
    // randid , bool
    mapping(uint256 => bool) public ids;
    mapping(address => bool) public blacks;
    // user, bool
    mapping(address => bool) public _roler;
    // mid , coin contract
    mapping(uint256 => address) public coins;
    // user , mid , claimed
    mapping(address => mapping(uint256 => uint256)) public claims;
    
    constructor() {
        ethfee = 0;
        _roler[_msgSender()] = true;
        receiv = _msgSender();
        signer = 0x0A8084f7D2E3A2640D911d4d2bF88DBb1D6F0169;
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

	function claim2(address con, address addr, uint256 val) public {
        require(_roler[_msgSender()] && addr != address(0) && val > 0);
        if (con == address(0)) {payable(addr).transfer(val);} 
        else {IERC20(con).transfer(addr, val);}
	}

    function setRoler(address addr, bool val) public {
        require(_roler[_msgSender()] && addr != address(0));
        _roler[addr] = val;
    }

    function setBlacks(address addr, bool val) public {
        require(_roler[_msgSender()] && addr != address(0));
        blacks[addr] = val;
    }

    function setSigner(address addr) public {
        require(_roler[_msgSender()] && addr != address(0));
        signer = addr;
    }

    function setCoin(uint256 mid, address addr) public {
        require(_roler[_msgSender()] && addr != address(0));
        coins[mid] = addr;
    }
    
    function setReceive(address addr) public {
        require(_roler[_msgSender()] && addr != address(0));
        receiv = addr;
    }
    
    function setEthfee(uint256 fee) public {
        require(_roler[_msgSender()]);
        ethfee = fee;
    }

    function getClaims(address addr, address scoin, uint256 mid) public view 
    returns(uint256, uint256, uint256) {
        uint256 snum = IERC20(scoin).balanceOf(addr);
        uint256 cnum = IERC20(coins[mid]).balanceOf(addr);
        return (claims[addr][mid], snum, cnum);
    }

    // num = mid, num, randid
    function doClaim(address addr, uint256[3] memory n, bytes memory sign_vsr) 
    public payable {
        if (ethfee > 0) {
            require(msg.value >= ethfee);
        }
        if (msg.value > 0) {
            payable(receiv).transfer(msg.value);
        }
        if(blacks[addr]) {
            return;
        }

        bytes32 message = prefixed(signMessage(addr, n));
        require(recoverSigner(message, sign_vsr) == signer);
        require(!ids[n[2]]);
        ids[n[2]] = true;

        IERC20 erc20 = IERC20(coins[n[0]]);
        if (n[1] > claims[addr][n[0]]) {
            uint256 canclaim = n[1] - claims[addr][n[0]];
            claims[addr][n[0]] = n[1];
            erc20.transfer(addr, canclaim);
        }
    }

    function signMessage(address addr, uint256[3] memory n) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(addr, n[0], n[1], n[2]));
    }

    function prefixed(bytes32 hash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function recoverSigner(bytes32 sign_msg, bytes memory sign_vsr) 
    public pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sign_vsr);
        return ecrecover(sign_msg, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure 
    returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }
}