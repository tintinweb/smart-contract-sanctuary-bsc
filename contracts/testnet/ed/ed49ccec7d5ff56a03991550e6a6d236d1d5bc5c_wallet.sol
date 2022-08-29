/**
 *Submitted for verification at BscScan.com on 2022-08-29
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
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address owner_) {
        _transferOwnership(owner_);
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

contract wallet is Ownable {
    //钱包共有人
    address[] public Partnerwallet;
    //授权所需人数
    uint256 public Authorize;

    constructor(address[] memory _addr, uint256 _Au)
        Ownable(0x0000000000000000000000000000000000000000)
    {
        Partnerwallet = _addr;
        Authorize = _Au;
    }


    mapping(uint256 => address) id; //id对应代币
    mapping(uint256 => address[]) Votedaddress; //已经投票地址
    mapping(uint256 => address[]) Paymentaddress; //收款地址
    mapping(uint256 => uint256[]) Receiptamount; //收款数量
    mapping(address => uint256[]) Initiaterecord;
    uint256 counter; //计数器
    uint[] proposals; //未签名提案
    uint[] signed; //已签名提案

 
    function Withdrawalapplication(
        address _token,
        address[] memory _Payment,
        uint256[] memory shu
    ) public {

        bool Partner = false;
        for (uint256 i = 0; i < (Partnerwallet.length - 1); i++) {
            if (msg.sender == Partnerwallet[i]) {
                Partner = true;
            }
        }

        if (Partner == true) {
            counter++;
            id[counter] = _token;
         
            Paymentaddress[counter] = _Payment;
            
            Receiptamount[counter] = shu;
      
            Initiaterecord[msg.sender].push(counter);
           
            signed.push(counter);
        }
    }

    function tion(uint256 index) public {
        //判断有没有投票资格
        bool Partner = false;
        for (uint16 i = 0; i < Partnerwallet.length; i++) {
            if (msg.sender == Partnerwallet[i]) {
                Partner = true;
            }
        }
   
        bool whether = true;
        if (Votedaddress[index].length != 0) {
            for (uint16 i = 0; i < Votedaddress[index].length; i++) {
                if (
                    msg.sender == Votedaddress[index][i] ||
                    Votedaddress[index].length >= Authorize
                ) {
                    whether = false;
                }
            }
        }
     
        if (Partner == true && whether == true) {
            
            Votedaddress[index].push(msg.sender);
        }
       
        if (whether == true && Votedaddress[index].length == Authorize) {
           
            if (id[index] == 0x0000000000000000000000000000000000000000) {
                //转ETH
                for (uint256 i = 0; i < Paymentaddress[index].length; i++) {
                    payable(Paymentaddress[index][i]).transfer(
                        Receiptamount[index][i]
                    );
                }
            } else {
                //转普通代币
                IERC20 token = IERC20(id[index]);
                for (uint256 i = 0; i < Paymentaddress[index].length; i++) {
                    token.transfer(
                        Paymentaddress[index][i],
                        Receiptamount[index][i]
                    );
                }
            }

            
        }
    }

    function nimade() public view returns (address) {
        return msg.sender;
    }


    function getViewpoll(uint index)
        public
        view
        returns (
            uint,
            address,
            address[] memory,
            address[] memory,
            uint[] memory
        )
    {

        return (
            index,
            id[index],
            Votedaddress[index],
            Paymentaddress[index],
            Receiptamount[index]
        );
    }

    function getbanan() public view returns (uint256) {
     
        return address(this).balance;
    }

    function tansferthis() public payable {
        payable(address(this)).transfer(msg.value);
    }

    
    function tansfertoaccount(address account, uint256 shu) public payable {
        payable(account).transfer(shu);
    }

 
    fallback() external payable {}

   
    receive() external payable {}
}