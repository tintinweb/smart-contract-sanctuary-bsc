/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}
interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function getOwner() external view returns (address);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }   

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract MetaSage is Ownable{
    IERC20 public token;
    uint256 public batchusers = 0;
    uint256 public totaluser = 0;

    struct User {
        address my_address;       
        uint256 sponsor_id;
        uint40 directs;        
        uint256 total_balance;       
        uint256 direct_commision;       
        uint256 claimed;               
        uint256 total_deposit;               
        uint40 timestamp;       
    }

    struct Batchstatus {
        uint40 b1;        
        uint40 b2;        
        uint40 b3;        
        uint40 b4;        
        uint40 b5;        
        uint40 b6;        
        uint40 b7;        
    }

    struct Batchdata {
        uint256 batchid;
        uint256[] bch1;        
        uint256[] bch2;        
        uint256[] bch3;        
        uint256[] bch4;        
        uint256[] bch5;        
        uint256[] bch6;        
        uint256[] bch7;        
    }

    struct poolparents{

        uint256 b1;
        uint256 b2;
        uint256 b3;
        uint256 b4;
        uint256 b5;
        uint256 b6;
        uint256 b7;
    }
    struct userinfo{
        uint256 id;
        address sponsor;
        bool status;        
    }

    
    mapping (uint256 => uint256[]) public bch_plan; 

    constructor() {
        bch_plan[1] = [12500000000000000000,10000000000000000000,12500000000000000000];
        bch_plan[2] = [20000000000000000000,20000000000000000000,20000000000000000000,20000000000000000000];
        bch_plan[3] = [40000000000000000000,40000000000000000000,40000000000000000000,40000000000000000000];
        bch_plan[4] = [80000000000000000000,80000000000000000000,80000000000000000000,80000000000000000000];
        bch_plan[5] = [160000000000000000000,160000000000000000000,160000000000000000000,160000000000000000000];
        bch_plan[6] = [320000000000000000000,320000000000000000000,320000000000000000000,320000000000000000000];
        bch_plan[7] = [640000000000000000000,640000000000000000000,640000000000000000000,640000000000000000000];
        

        b2ids = [0,1];
        b4ids = [0,1];
        b6ids = [0,1];

        totaluser++;
        sp_info[msg.sender].id=totaluser;
        sp_info[msg.sender].status=true;      
        
        users[totaluser].my_address=msg.sender;
       

    }

    mapping (address => userinfo) public sp_info; 
    mapping (uint256 => User) public users; 
    mapping (uint256 => Batchdata) public Batch_data; 
    mapping (uint256 => Batchstatus) public Batch_status; 
    mapping (uint256 => poolparents) public PoolParent; 

    function adduser(uint256 nw,uint256 prnt) public returns (bool) {
        batchusers++;
        Batch_data[nw].batchid = batchusers;

        if(Batch_data[prnt].batchid!=0){
            Batch_data[prnt].bch1.push(nw);
        }        
        return true;
    }

    

    function register(uint256 sponsor) public returns(bool){
        
        require(sp_info[msg.sender].status==false,"User already exists");

        totaluser++;
        sp_info[msg.sender].id=totaluser;
        sp_info[msg.sender].status=true;
        sp_info[msg.sender].sponsor=users[sponsor].my_address;
        users[totaluser].sponsor_id=sponsor;
        users[totaluser].my_address=msg.sender;
        users[sponsor].directs++;

        return true;
    }



    function addb1(uint256 nw) public returns(bool){
        require(sp_info[msg.sender].id > 0,"Register your account before activate.");
        batchusers++;
        Batch_data[nw].batchid = batchusers;
        Batch_data[nw].bch1.push(nw);        

        uint256 lvl = 0;
        uint256 pid = users[nw].sponsor_id;

        bool plc = true;

        while (plc==true) {

            if(Batch_data[pid].batchid!=0){                
                plc = false;
            }else{
                pid =  users[pid].sponsor_id;
            }            
        }

        Batch_status[nw].b1 = 1;
        PoolParent[nw].b1 = pid;

        uint256 prid = pid;
        uint256 cnt_users;
        uint256 lvlcnt = 1;

        while (lvl<3) {
            if(prid!=0){
                Batch_data[prid].bch1.push(nw);
                cnt_users = Batch_data[prid].bch1.length;
                if(cnt_users>lvlcnt){
                    uint256 my_usrs = cnt_users-lvlcnt;
                    users[prid].total_balance += bch_plan[1][lvl];
                    if(lvl==2 && (my_usrs == 3|| my_usrs==4 || my_usrs == 7|| my_usrs==8)){
                        if(my_usrs==8){
                            delete Batch_data[prid].bch1;
                            Batch_data[prid].bch1.push(prid);
                            addb1(prid);
                        }
                    }
                }            
                prid = PoolParent[prid].b1;
            }  
            lvlcnt = lvlcnt + (2 ** lvl);          
            lvl++;
        }       
        return true;
    }

    uint256[] public b2ids;
    uint256[] public b4ids;
    uint256[] public b6ids;

    function addb2(uint256 nw)public returns(bool){
           
        uint256 ttllnth = b2ids.length;
        Batch_data[nw].bch2.push(nw);  

       
       uint256 prid;
       

       uint256 lvl = 0;        
       uint256 cnt_users;        
       uint256 lvlcnt = 1;        
       uint256 usr;
       while (lvl<4){            
           uint256 dv_by = 2 ** (lvl+1);
           prid = ttllnth/dv_by;

           if(prid>0){
                usr = b2ids[prid];           
                Batch_data[usr].bch2.push(nw);
                cnt_users = Batch_data[usr].bch2.length;                
                if(cnt_users>lvlcnt){            
                    uint256 my_usrs = cnt_users-lvlcnt;           

                    if(lvl==3 && (my_usrs == 7|| my_usrs==8 || my_usrs == 14 || my_usrs==15 || my_usrs==16)){
                        if(my_usrs==16){
                            delete Batch_data[usr].bch2;
                            Batch_data[usr].bch2.push(usr);
                            return addb2(usr);
                        }
                    }else{
                        users[usr].total_balance += bch_plan[2][lvl];
                    } 
                }
           }
           lvlcnt = lvlcnt + (2 ** lvl);     

           lvl++;
        }      
        b2ids.push(nw);
        return true;
    }

    function addb4(uint256 nw)public returns(bool){
        //b2ids.push(nw);   
        uint256 ttllnth = b4ids.length;
        Batch_data[nw].bch4.push(nw);  

        //uint256 dvby = ttllnth/2;
        uint256 prid;
        //Batch_data[prid].bch2.push(nw);

        uint256 lvl = 0;        
        uint256 cnt_users;        
        uint256 lvlcnt = 1;        
        uint256 usr;
        while (lvl<4){            
            uint256 dv_by = 2 ** (lvl+1);
            prid = ttllnth/dv_by;
            usr = b4ids[prid];
            users[usr].total_balance += bch_plan[4][lvl];               
            Batch_data[usr].bch4.push(nw);
            if(cnt_users>lvlcnt){   
                cnt_users = Batch_data[usr].bch4.length;                

                uint256 my_usrs = cnt_users-lvlcnt;           

                if(lvl==3 && (my_usrs == 7|| my_usrs==8 || my_usrs == 14 || my_usrs==15 || my_usrs==16)){
                    if(my_usrs==16){
                        delete Batch_data[usr].bch4;
                        Batch_data[usr].bch4.push(usr);
                        return addb4(usr);
                    }
                } 
            }
            lvlcnt = lvlcnt + (2 ** lvl);     

            lvl++;
        }      
        
        return true;
    }
    
    function addb6(uint256 nw)public returns(bool){
        //b2ids.push(nw);   
        uint256 ttllnth = b6ids.length;
        Batch_data[nw].bch6.push(nw);  

        //uint256 dvby = ttllnth/2;
        uint256 prid;
        //Batch_data[prid].bch2.push(nw);

        uint256 lvl = 0;        
        uint256 cnt_users;        
        uint256 lvlcnt = 1;        
        uint256 usr;
        while (lvl<4){            
            uint256 dv_by = 2 ** (lvl+1);
            prid = ttllnth/dv_by;
            usr = b6ids[prid];
            users[usr].total_balance += bch_plan[6][lvl];               
            Batch_data[usr].bch6.push(nw);
            if(cnt_users>lvlcnt){   
                cnt_users = Batch_data[usr].bch6.length;                

                uint256 my_usrs = cnt_users-lvlcnt;           

                if(lvl==3 && (my_usrs == 7|| my_usrs==8 || my_usrs == 14 || my_usrs==15 || my_usrs==16)){
                    if(my_usrs==16){
                        delete Batch_data[usr].bch6;
                        Batch_data[usr].bch6.push(usr);
                        return addb6(usr);
                    }
                } 
            }
            lvlcnt = lvlcnt + (2 ** lvl);     

            lvl++;
        }      
        
        return true;
    }

    function addb3(uint256 nw) public returns(bool){
        require(sp_info[msg.sender].id > 0,"Register your account before activate.");

        //batchusers++;
        //Batch_data[nw].batchid = batchusers;
        Batch_data[nw].bch3.push(nw);

        uint256 lvl = 0;
        uint256 pid = users[nw].sponsor_id;

        bool plc = true;

        while (plc==true) {

            if(Batch_status[pid].b3!=0){                
                plc = false;
            }else{
                pid =  users[pid].sponsor_id;
            }            
        }

        Batch_status[nw].b3 = 1;
        PoolParent[nw].b3 = pid;

        uint256 prid = pid;
        uint256 cnt_users;
        uint256 lvlcnt = 1;

        while (lvl<4) {
            if(prid!=0){
                Batch_data[prid].bch3.push(nw);
                cnt_users = Batch_data[prid].bch3.length;                
                if(cnt_users>lvlcnt){   
                    uint256 my_usrs = cnt_users-lvlcnt;
                    users[prid].total_balance += bch_plan[3][lvl];

                    if(lvl==3 && (my_usrs == 7|| my_usrs==8 || my_usrs == 14 || my_usrs==15 || my_usrs==16)){
                        if(my_usrs==16){
                            delete Batch_data[prid].bch3;
                            Batch_data[prid].bch3.push(prid);
                            return addb3(prid);
                        }
                    } 
                }           
                prid = PoolParent[prid].b3;
            }
            lvlcnt = lvlcnt +  (2 ** lvl);     
            lvl++;
        }       
        return true;
    }

    function addb5(uint256 nw) public returns(bool){
        require(sp_info[msg.sender].id > 0,"Register your account before activate.");

        //batchusers++;
        //Batch_data[nw].batchid = batchusers;
        Batch_data[nw].bch5.push(nw);

        uint256 lvl = 0;
        uint256 pid = users[nw].sponsor_id;

        bool plc = true;

        while (plc==true) {

            if(Batch_status[pid].b5!=0){                
                plc = false;
            }else{
                pid =  users[pid].sponsor_id;
            }            
        }

        Batch_status[nw].b5 = 1;
        PoolParent[nw].b5 = pid;

        uint256 prid = pid;
        uint256 cnt_users;
        uint256 lvlcnt = 1;

        while (lvl<4) {
            if(prid!=0){
                Batch_data[prid].bch5.push(nw);
                cnt_users = Batch_data[prid].bch5.length;                
                if(cnt_users>lvlcnt){   
                    uint256 my_usrs = cnt_users-lvlcnt;
                    users[prid].total_balance += bch_plan[5][lvl];

                    if(lvl==3 && (my_usrs == 7|| my_usrs==8 || my_usrs == 14 || my_usrs==15 || my_usrs==16)){
                        if(my_usrs==16){
                            delete Batch_data[prid].bch5;
                            Batch_data[prid].bch5.push(prid);
                            return addb5(prid);
                        }
                    }
                }            
                prid = PoolParent[prid].b5;
            }
            lvlcnt = lvlcnt + (2 ** lvl);     
            lvl++;
        }       
        return true;
    }

    function addb7(uint256 nw) public returns(bool){
        require(sp_info[msg.sender].id > 0,"Register your account before activate.");

        //batchusers++;
        //Batch_data[nw].batchid = batchusers;
        Batch_data[nw].bch7.push(nw);

        uint256 lvl = 0;
        uint256 pid = users[nw].sponsor_id;

        bool plc = true;

        while (plc==true) {

            if(Batch_status[pid].b7!=0){                
                plc = false;
            }else{
                pid =  users[pid].sponsor_id;
            }            
        }

        Batch_status[nw].b7 = 1;
        PoolParent[nw].b7 = pid;

        uint256 prid = pid;
        uint256 cnt_users;
        uint256 lvlcnt = 1;

        while (lvl<4) {
            if(prid!=0){
                Batch_data[prid].bch7.push(nw);
                cnt_users = Batch_data[prid].bch7.length;                
                if(cnt_users>lvlcnt){   
                    uint256 my_usrs = cnt_users-lvlcnt;
                    users[prid].total_balance += bch_plan[7][lvl];

                    if(lvl==3 && (my_usrs == 7|| my_usrs==8 || my_usrs == 14 || my_usrs==15 || my_usrs==16)){
                        if(my_usrs==16){
                            delete Batch_data[prid].bch7;
                            Batch_data[prid].bch7.push(prid);
                            return addb7(prid);
                        }
                    }  
                }          
                prid = PoolParent[prid].b7;
            }
            lvlcnt = lvlcnt + (2 ** lvl);     
            lvl++;
        }       
        return true;
    }
}