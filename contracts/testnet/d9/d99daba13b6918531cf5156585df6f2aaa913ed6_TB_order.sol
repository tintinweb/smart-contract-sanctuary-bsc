// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;

import "./draft-EIP712.sol";

// npx hardhat run scripts/1_develop_main.js --network bnbtest
// npx hardhat verify 0xd6F596C7E3eb6EadeaE62d6952B83b994665074b --network bnbtest

// contract B_order{
contract TB_order is EIP712{
    constructor() EIP712("VII_order", "1")
    {
        owner=msg.sender;
    }

    address private owner;
    
    address constant public usdc=0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address constant private weth=0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address constant private pair=0xF855E52ecc8b3b795Ac289f85F6Fd7A99883492b;

    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("order(uint256 order,uint256 amount,uint256 deadline)");

    event Order(uint256 indexed order,uint256 indexed amount);
    mapping(uint256=>uint256) public order_state;

    function eorder(uint256 order,uint256 amount ,uint256 deadline ,uint8 v,bytes32 r,bytes32 s)payable public{
        require(tx.origin==msg.sender,"order: can't use contract");
        require(deadline>block.timestamp,"order: time error");
        check(order,amount,deadline,v,r,s);
        uint256 eamount;
        unchecked{
            eamount = amount*uethprice()/10**IERC20(usdc).decimals();
            require(msg.value>=eamount,"order: error eth amount");
            payable(msg.sender).transfer(msg.value-eamount);
            payable(owner).transfer(address(this).balance);
            require(order_state[order]==0,"order: order completed");
            order_state[order] = amount*(10**(18-IERC20(usdc).decimals()));
        }
        emit Order(order,order_state[order]);
    }

    function uorder(uint256 order,uint256 amount ,uint256 deadline ,uint8 v,bytes32 r,bytes32 s)public{
        require(deadline>block.timestamp,"order: time error");
        check(order,amount,deadline,v,r,s);
        IERC20(usdc).transferFrom(msg.sender,owner,amount);
        require(order_state[order]==0,"order: order completed");
        unchecked{
            order_state[order] = amount*(10**(18-IERC20(usdc).decimals()));
        }
        emit Order(order,amount);
    }

    function check(uint256 order,uint256 amount ,uint256 deadline ,uint8 v,bytes32 r,bytes32 s)private view{
        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, order, amount, deadline));
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "order: signer invalid signature");
    }
    function uethprice()view public returns(uint256 price){
        unchecked{
            price = IERC20(weth).balanceOf(pair)*
            10**IERC20(usdc).decimals()/
            IERC20(usdc).balanceOf(pair);
        }
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function decimals() external view returns (uint256);
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
}