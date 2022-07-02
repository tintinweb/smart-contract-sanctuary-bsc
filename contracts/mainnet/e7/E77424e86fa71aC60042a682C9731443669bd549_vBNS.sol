/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier: MIT

//vBNS Token Airdrop

// https://bns.id

//  ____  _   _ ____
// | __ )| \ | / ___|
// |  _ \|  \| \___ \
// | |_) | |\  |___) |
// |____/|_| \_|____/

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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

library SafeMath {
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

abstract contract BNS {
    function resolver(bytes32 node) public view virtual returns (Resolver);
}

abstract contract Resolver {
    function addr(bytes32 node) public view virtual returns (address);
}

contract vBNS is IERC20 {
    using SafeMath for uint256;

    string public name = "vBNS";
    string public symbol = "vBNS";
    uint8 public decimals = 18;
    uint256 totalSupply_ = 0;

    BNS bns = BNS(0x0000000092F9d53192ED545D9dF4fDE3C624cBf0);

    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
    event Transfer(address indexed from, address indexed to, uint256 tokens);

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(bytes32 => bool) public status;

    function claim(bytes32 inviterNode, bytes32 mynode) external {
        address inviterAddress = resolve(inviterNode);
        address myAddress = resolve(mynode);
        require(
            status[mynode] == false,
            "This domain name has already been claimed"
        );
        require(
            msg.sender == myAddress,
            "This domain name does not point to your address"
        );
        require(inviterAddress != myAddress, "You can't invite yourself");
        _mint(inviterAddress, 30);
        _mint(myAddress, 70);
        status[mynode] = true;
    }

    function claimWithoutInviter(bytes32 mynode) external {
        address myAddress = resolve(mynode);
        require(
            status[mynode] == false,
            "This domain name has already been claimed"
        );
        require(
            msg.sender == myAddress,
            "This domain name does not point to your address"
        );
        _mint(myAddress, 50);
        status[mynode] = true;
    }

    function resolve(bytes32 node) public view returns (address) {
        Resolver resolver = bns.resolver(node);
        return resolver.addr(node);
    }

    function _mint(address receiver, uint256 amount) internal returns (bool) {
        require(totalSupply_ <= 25000000 * 10**18);
        require(receiver != address(0), "ERC20: mint to the zero address");
        balances[receiver] = balances[receiver].add(amount * 10**18);
        totalSupply_ = totalSupply_.add(amount * 10**18);
        emit Transfer(address(0), receiver, amount * 10**18);
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256)
    {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens)
        public
        override
        returns (bool)
    {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens)
        public
        override
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        override
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function transferFrom(
        address owner,
        address buyer,
        uint256 numTokens
    ) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}