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
        for (uint16 i = 0; i < _addr.length; i++){
         partner[_addr[i]]=true;           
        }
    }

    mapping(uint256 => address) id; //id对应代币
    mapping(uint256 => address[]) Votedaddress; //已经投票地址
    mapping(uint256 => address[]) Paymentaddress; //收款地址
    mapping(uint256 => uint256[]) Receiptamount; //收款数量
    mapping(address => uint256[]) Initiaterecord;//用户提案编号
    mapping(address=>bool) partner;//是否合伙人
    mapping(uint=>mapping(address=>bool)) Whethertovote;//是否投票Whethertovote[id][address]
    uint256 counter; //计数器
    uint[] proposals; //未签名提案
    uint[] signed; //已签名提案

    function Withdrawalapplication(
        address _token,
        address[] memory _Payment,
        uint256[] memory shu
    ) public  {
        //判断是否是合伙人
        require(partner[msg.sender]==true);  
            counter++;
            id[counter] = _token;
            //存提款地址
            Paymentaddress[counter] = _Payment;
            //存提现金额
            Receiptamount[counter] = shu;
            //添加个人记录
            Initiaterecord[msg.sender].push(counter);
            //添加到未签名提案
            proposals.push(counter);   
    }

    function sign(uint256 index) public {
        //到时候还需要判断 余额是否足够
        //判断有没有投票资格
     require(partner[msg.sender]==true); 
        //判断投票还没达标;
     require(Votedaddress[index].length < Authorize); 
        //判断此地址是否已经投票
     require(Whethertovote[index][msg.sender] != true); 
        //投票
          Votedaddress[index].push(msg.sender);
         //msg.sender投票等于真
          Whethertovote[index][msg.sender]=true;
        //这里判断投票是否达标   如果达标  给他们转账 即可
        if (Votedaddress[index].length == Authorize) {
            //这里循环转账ADD  是代币地址
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
            //添加到已完结投票里面
            signed.push(index);
        }
    }

//查看单用户投票
function whethertovote(uint index,address _addr) view public returns (bool) {    
return Whethertovote[index][_addr];
}
//查看用户提案编号
function initiaterecord(address _addr) view public returns (uint[] memory) {    
return Initiaterecord[_addr];
}
//查看全部
function Proposals() view public returns (uint[] memory) {    
return proposals;
}
//查看已经完成的提案编号
function Signed() view public returns (uint[] memory) {    
return signed;
}

    //获取所有信息
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

 
    function ETHbalance() public view returns (uint256) {
        return address(this).balance;
    }


    fallback() external payable {}


    receive() external payable {}
}