/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

pragma solidity ^0.8.5;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract marketWallet {

    mapping(address=>bool) admin;
    mapping(uint256=>bool) active;
    mapping(uint256=>uint256) Type;
    /*
    Type = 1  setadmin
    Type = 2  rmadmin
    Type = 3  bnb transfer
    Type = 4  token transfer
    Type = 5  set needConfirmNum
    */
    mapping(uint256=>address) waiteSetAdmin;
    mapping(uint256=>address) waiteRmAdmin;
    mapping(uint256=>address) waiterTransferTo;
    mapping(uint256=>uint256) waiterTransferAmount;
    mapping(uint256=>address) waiterTransferToken;
    mapping(uint256=>uint256) waiteSetneedConfirmNum;

    mapping(uint256=>address[]) adminIsDone;

    mapping(uint256=>uint256) getVotes;
    mapping(uint256=>uint256) lostVotes;

    uint256 public needConfirmNum;
    uint256 public adminNum;

    event activeChange(uint256 id,bool _active);
  //  address[] admins;
  //  mapping (address => uint256) adminsIndexes;

    constructor () {
        address adr1 = 0xf6653d91b76f2eDB65d23712903Cd81ce1803977; //shuimu
        address adr2 = 0x0D9E0b1A492Fa228960c0fEACb43067266099949; //tingyu
        address adr3 = 0x09374a8F1a4968e52E5FDd3126A766E77A8F1d78; //ann
        address adr4 = 0x7efD2CfaEd425f5f5b8a212FDc66a36b7eF67d9B; //lanwang
        address adr5 = 0x5E7B5f0847aAa0B4864e37383f8374C91559719c; //zhenghao

        _addAdmins(adr1);
        _addAdmins(adr2);
        _addAdmins(adr3);
        _addAdmins(adr4);
        _addAdmins(adr5);

        needConfirmNum = 3;
        adminNum = 5;

    }
    modifier onlyAdmin() {
        require(admin[msg.sender], "Ownable: caller is not the admin");
        _;
    }
    receive() external payable {}
    function checkisDone(address adr,uint256 id)public view returns(bool){
        address[] storage adrs = adminIsDone[id];
        for(uint256 i = 0;i<adrs.length;i++){
            if(adrs[i] == adr){return true;}
        }
        return false;
    }
    function isDone(address adr,uint256 id)internal{
        address[] storage adrs = adminIsDone[id];
        adrs.push(adr);
    }

    function _addAdmins(address adr)internal{
    //    adminsIndexes[adr] = admins.length;
    //    admins.push(adr);
        admin[adr] = true;
    }
    function _rmAdmins(address adr)internal{
   //     admins[adminsIndexes[adr]] = admins[admins.length-1];
   //     adminsIndexes[admins[admins.length-1]] = adminsIndexes[adr];
   //     admins.pop();
        admin[adr] = false;
    }

    function rmDone(uint256 id)internal{
            address[] storage adrs = adminIsDone[id];
            uint256 num = adrs.length;
            for(uint256 i = 0;i<num;i++){
                adrs.pop();
        }
    }
    function isAdmin(address adr)public view returns(bool){
        return admin[adr];
    }

    function setAdmin(address adr,uint256 id) public onlyAdmin{
        require(!active[id],"id is using!");
        waiteSetAdmin[id] = adr;
        active[id] = true;
        emit activeChange(id,true);
        Type[id] = 1;
        getVotes[id] = 1;
        lostVotes[id] = 0;
        rmDone(id);
        isDone(msg.sender,id);
        checkVoteAndDO(id);
        
    }

    function rmAdmin(address adr,uint256 id) public onlyAdmin{
        require(!active[id],"id is using!");
        require(admin[adr],"adr is not admin!");
        require(adminNum -1 >= needConfirmNum,"set needconfirmnum first");
        waiteRmAdmin[id] = adr;
        active[id] = true;
        emit activeChange(id,true);
        Type[id] = 2;
        getVotes[id] = 1;
        lostVotes[id] = 0;
        rmDone(id);
        isDone(msg.sender,id);
        checkVoteAndDO(id);
      //  emit activeChange(id,true);
    }

    

    function transferBNB(address to,uint256 amount,uint256 id) public onlyAdmin{
        require(!active[id],"id is using!");
        require(address(this).balance >= amount,"too much");
        waiterTransferTo[id] = to;
        waiterTransferAmount[id] = amount;
        active[id] = true;
        emit activeChange(id,true);
        Type[id] = 3;
        getVotes[id] = 1;
        lostVotes[id] = 0;
        rmDone(id);
        isDone(msg.sender,id);
        checkVoteAndDO(id);
      //  emit activeChange(id,true);
    }

    function transferToken(address token,address to,uint256 amount,uint256 id) public onlyAdmin{
        require(!active[id],"id is using!");
        require(IBEP20(token).balanceOf(address(this)) >= amount,"too much");
        waiterTransferTo[id] = to;
        waiterTransferAmount[id] = amount;
        waiterTransferToken[id] = token;
        active[id] = true;
        emit activeChange(id,true);
        Type[id] = 4;
        getVotes[id] = 1;
        lostVotes[id] = 0;
        rmDone(id);
        isDone(msg.sender,id);
        checkVoteAndDO(id);
       // emit activeChange(id,true);
    }

    function setneedConfirmNum(uint256 num,uint256 id)public onlyAdmin{
        require(!active[id],"id is using!");
        require(num <= adminNum,"num is too much!");
        require(num > 0,"num is 0");
        waiteSetneedConfirmNum[id] = num;
        active[id] = true;
        emit activeChange(id,true);
        Type[id] = 5;
        getVotes[id] = 1;
        lostVotes[id] = 0;
        rmDone(id);
        isDone(msg.sender,id);
        checkVoteAndDO(id);
       // emit activeChange(id,true);
    }

    function getTransById(uint256 id) public view returns(
        address setadmin,address rmadmin,address to,uint256 amount,address token,uint256 setconfirmNum,uint256 votes,uint256 _type,bool _active){
            setadmin = waiteSetAdmin[id];
            rmadmin = waiteRmAdmin[id];
            to = waiterTransferTo[id];
            amount = waiterTransferAmount[id];
            token = waiterTransferToken[id];
            _type = Type[id];
            _active = active[id];
            setconfirmNum = waiteSetneedConfirmNum[id];
            votes = getVotes[id];
    }  

    function vote(uint256 id, uint256 confirm) public onlyAdmin{
        require(active[id],"id is not active!");
        require(!checkisDone(msg.sender,id),"is Done");
        isDone(msg.sender,id);
        if(confirm == 1){
            getVotes[id] = getVotes[id] +1 ;
            checkVoteAndDO(id);
        }else{
            lostVotes[id] += 1;
        }

        if(getVotes[id] + lostVotes[id] >= adminNum){
            active[id] = false;
            emit activeChange(id,false);
        }
    } 

    function checkVoteAndDO(uint256 id) internal {
        if(getVotes[id] >= needConfirmNum){
                active[id] = false;
                emit activeChange(id,false);

                if(Type[id] == 1){
                    _addAdmins(waiteSetAdmin[id]);
                    adminNum = adminNum +1 ;
                }
                if(Type[id] == 2){
                    _rmAdmins(waiteRmAdmin[id]);
                    adminNum = adminNum -1 ;
                    require(adminNum >= needConfirmNum,"needConfirmnum is too low");
                }
                if(Type[id] == 3){
                    payable(waiterTransferTo[id]).transfer(waiterTransferAmount[id]);
                }
                if(Type[id] == 4){
                    IBEP20(waiterTransferToken[id]).transfer(waiterTransferTo[id],waiterTransferAmount[id]);
                }
                if(Type[id] == 5){
                    needConfirmNum = waiteSetneedConfirmNum[id];
                    require(adminNum >= needConfirmNum,"needConfirmnum is too high");
                }
            }
    }
}