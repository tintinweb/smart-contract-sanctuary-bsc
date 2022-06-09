/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

pragma solidity >=0.6.0 <0.8.0;
 interface ERC20 {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver)external view returns(uint256);
    function getTeam(address addr)external view returns(address);
    function approve(address spender, uint amount) external returns (bool);
}
interface NFTToken{
    function ownerOf(uint256 _tokenId) external view returns (address);
    function transferFrom(address _from, address _to, uint256 _value)external;
    function mint(address toAddress)external;
    function balanceOf(address _owner) external view returns (uint256);
    function tokenNextId()external view returns (uint256);
    function burn(address _owner, uint256 _tokenId) external;
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}
}
interface IPancakeRouter01 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}
interface PCDprice {
    function getEX()external view returns(uint256);
}
interface pancakeswap{
     function addLiquidity(uint256 _usdt)external;
}
contract PCDNFT{
    using SafeMath for uint256;
    address public owner;
    uint256 public priceOne;//NFT价格
    uint256 public priceTwo;//NFT价格
    uint256 public priceThree;//NFT价格
    uint256 public stopTime;
    //address public pancakeRouter=0xED7d5F38C79115ca12fe6C0041abb22F0A06C300;
    //address public token=0x762d74058FC9Ce6162b47Ab2D318497e58c544ED;
    //address public usdtToken=0xa71EdC38d189767582C38A3145b5873052c3e47a;
    address public pancakeRouter=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public token=0xE4f1AE07760b985D1A94c6e5FB1589afAf44918c;
    address public usdtToken=0x55d398326f99059fF775485246999027B3197955;
    mapping(uint256 => uint256) public NFTID;
    ERC20 public USDT;
    mapping(uint256 => mapping(address => uint256)) public OneNftOf;
    mapping(uint => mapping(uint => address)) public nftOwner;//被谁抢到
    mapping(address => bool) public activation;//激活钱包
    mapping(uint =>mapping(address => bool)) public makeAppointment;//预约抢单
    mapping(address => bool) public Orders;//抢单是否成功
    mapping(uint256 =>mapping(uint256 =>uint)) public OrdersTime;//支付倒计时   
    mapping(uint => uint) public OrdersStop;
    mapping(address =>user) public users;
    mapping(uint => address)public tokens;//NFT合约地址 10001=S 10002=ss 10003=sss
    mapping(uint =>mapping(uint => NFTT)) public nfts;
    mapping(uint256 => mapping(address => uint256)) public DirectPushTime;
    mapping(address =>uint[])public nftShouc;
    address public pcdPriceAddress;
    uint256 mnus;
    struct user{
        address upaddress;
        uint256 DirectP;
        uint256 pcd;//PCD待释放量
        uint256 OKpcd;//已经释放PCD量
        uint256 lastTime;
        uint256 usdt;
        uint256 Spcd;
        uint bz;
        address[] taem;
        uint[] nfts;
       }
       struct NFTT{
           address addr;
           uint price;
           uint times;
       }
    modifier onlyOwner() {
        require(owner==msg.sender, "Not an administrator");
        _;
    }
    constructor()public{
         owner=msg.sender;
         USDT=ERC20(usdtToken);
         OrdersStop[1]=1654774200;
         OrdersStop[2]=1654759800;
         OrdersStop[3]=1654745400;
         NFTID[1]=1;
         NFTID[2]=1;
         NFTID[3]=1;
         priceOne=100 ether;
         priceTwo= 200 ether;
         priceThree= 500 ether;
         OrdersStop[100000000001]=1;
         OrdersStop[100000000002]=1;
         OrdersStop[100000000003]=1;
         OrdersStop[100000000006]=1;
         OrdersStop[100000000007]=1;
         OrdersStop[100000000008]=1;
         OrdersStop[100000000004]=2000 ether;
         OrdersStop[100000000005]=20000 ether;
        stopTime=1654790400;//每天24点
        users[msg.sender].bz=1;
        pcdPriceAddress=0x65143ba191155d5F1F8608383C81F0ab5f812902;
        ERC20(token).approve(pancakeRouter,2 ** 256 - 1);
     }
     function setPrice()public{
         if(block.timestamp > stopTime){
         stopTime += 1 days;
         OrdersStop[1]+= 1 days;
         OrdersStop[2]+= 1 days;
         OrdersStop[3]+= 1 days;
         OrdersStop[100000000001]=OrdersStop[100000000006];
         OrdersStop[100000000002]=OrdersStop[100000000007];
         OrdersStop[100000000003]=OrdersStop[100000000008]; 
         }       
     }
    function getEX(uint va)public view returns(uint256){
        uint p=PCDprice(pcdPriceAddress).getEX();
        uint v=va * 1 ether / p;       
        return v;
    }
    function setTokens(address addr,uint a)public onlyOwner{
         tokens[a]=addr;
     }
     function AppCc(address _token,address to) public onlyOwner{
         ERC20(_token).approve(to,2 ** 256 - 1);
     }
     function setUsdt(address addr,uint _usdt) public{
         require(!activation[msg.sender] && users[addr].bz == 1);
           ERC20(token).transferFrom(msg.sender,address(this),OrdersStop[100000000004]);
           ERC20(token).transfer(0x9f8fE7A2215eD1a1eB1285F9aE97C3B6c6552398,OrdersStop[100000000004]);
           activation[msg.sender]=true;
           if(users[msg.sender].upaddress == address(0) && addr != msg.sender){
               users[msg.sender].upaddress=addr;
               users[addr].taem.push(msg.sender);
           }
           users[msg.sender].bz=1;
     }
     function Appointment(uint256 a)public {
         require(!makeAppointment[a][msg.sender] && activation[msg.sender]);
         ERC20(token).transferFrom(msg.sender,address(this),OrdersStop[100000000005]);
         makeAppointment[a][msg.sender]=true;//预约成功
     }
     //抢单,a=1 s a=2 ss a=3 sss
     function GrabOrders(uint256 a)public{
         require(makeAppointment[a][msg.sender]);
         uint dayNfts;
         if(a==1){
            dayNfts=OrdersStop[100000000001];
            setGrabOrders(a);//预约数量增加
         }
         if(a==2){
             dayNfts=OrdersStop[100000000002];
               setGrabOrders(a);//预约数量增加
         }
         if(a==3){
             dayNfts=OrdersStop[100000000003];
             setGrabOrders(a);//预约数量增加
         }
         //读取NFT等级
         (uint256 a1,uint256 a2,uint256 a3,address nft)=getNFTlevel(a,dayNfts);
         uint oknft=OrdersTime[a][9999999999];//最多只能抢预约总量的80%
         require(oknft > dayNfts && block.timestamp > a3 && NFTToken(nft).ownerOf(dayNfts) !=msg.sender);
        //这里需要注意，应该是每个等级NFT都是对应的时间
            OrdersTime[a][dayNfts]=block.timestamp + 86400;
            Orders[msg.sender]=true;
            nftOwner[a][dayNfts]=msg.sender;
            makeAppointment[a][msg.sender]=false;
            DirectPushTime[a][msg.sender]=a3+1 days;
            OneNftOf[a][msg.sender]=dayNfts;    
     }
     function shouchan(uint a)public{
         (uint256 a1,,,address nftaddress)=getNFTlevel(a,1);
         USDT.transferFrom(msg.sender,address(this),a1);
        ERC20(usdtToken).transfer(0xf10F6F656Ca6fde4e78DC2cE70BEF35f056C7496,a1 * 70 / 100);
        uint256 _pcd=getEX(a1)*3;
        users[msg.sender].pcd+=_pcd;
        users[msg.sender].lastTime=block.timestamp;
        address up1=users[msg.sender].upaddress;
        address up2=users[up1].upaddress;
        address up3=users[up2].upaddress;
        uint256 upUSDT=a1*30/100;
        uint u;
        if(up1 != address(0)){
            USDT.transfer(up1,upUSDT*60/100);
        }else{
           u+=upUSDT*60/100;//如果没有直推，这60%USDT佣金买PCD销毁
        }
        if(up2 != address(0)){
            USDT.transfer(up2,upUSDT*25/100);//如果有2代，给与25%USDT奖金
        }else{
            u+=upUSDT*25/100;//如果没有2代，这25%USDT佣金买PCD销毁
        }
        if(up3 != address(0)){
            USDT.transfer(up3,upUSDT*15/100);//如果有3代，给与15%USDT奖金
        }else{
            u+=upUSDT*15/100;//如果没有3代，这15%USDT佣金买PCD销毁
        }
        if(u>0){
            ERC20(usdtToken).transfer(0xf10F6F656Ca6fde4e78DC2cE70BEF35f056C7496,u);
        }
        if(USDT.balanceOf(0xf10F6F656Ca6fde4e78DC2cE70BEF35f056C7496) > 200 ether){
           pancakeswap(0xf10F6F656Ca6fde4e78DC2cE70BEF35f056C7496).addLiquidity(200 ether);
        }
        NFTID[1]=NFTToken(tokens[10001]).tokenNextId()-1;
        NFTID[2]=NFTToken(tokens[10002]).tokenNextId()-1;
        NFTID[3]=NFTToken(tokens[10003]).tokenNextId()-1;
     }
     function getDayPcd(address addr)public view returns(uint256){
         uint256 va;
         if(block.timestamp > users[addr].lastTime){
             va=block.timestamp.sub(users[addr].lastTime);
         }else{
             va=0;
         }
         uint256 vav;
         if(users[addr].pcd > users[addr].OKpcd && va > 0){
            //va=users[addr].pcd.sub(users[addr].OKpcd);
           uint256 _vav=users[addr].pcd.div(4320000).mul(va);//计算出50天，每秒产量
            if(_vav+users[addr].OKpcd > users[addr].pcd){
              vav=(_vav+users[addr].OKpcd).sub(users[addr].pcd);
            }else{
              vav=_vav;
            }
         }else{
            vav=0;//计算出50天，每秒产量
         }
         return vav;
     }
     //挖矿
     function sendPcd()public{
         require(users[msg.sender].pcd > users[msg.sender].OKpcd,"End of mining");
         uint256 amount=getDayPcd(msg.sender);
         users[msg.sender].OKpcd+=amount;
         users[msg.sender].lastTime=block.timestamp;
         ERC20(token).transfer(msg.sender,amount*90/100);
         uint pl=amount*10/100;
         ERC20(token).transfer(0x1A915bEA1eBc398Fb02d437533C06c021dEe53BF,pl*60/100);
         ERC20(token).transfer(0x9f8fE7A2215eD1a1eB1285F9aE97C3B6c6552398,pl*30/100);
         ERC20(token).transfer(0x4110C11Cc5CAcF26E749B575bA49661a7069d362,pl*10/100);
         if(USDT.balanceOf(0xf10F6F656Ca6fde4e78DC2cE70BEF35f056C7496) > 50 ether){
           pancakeswap(0xf10F6F656Ca6fde4e78DC2cE70BEF35f056C7496).addLiquidity(50 ether);
        }
     }
     function setGrabOrders(uint a)internal{
         if(a == 1){
             OrdersStop[100000000001]++;
         }else if(a == 2){
             OrdersStop[100000000002]++;
         }else if(a == 3){
             OrdersStop[100000000003]++;
         }
     }
     //付款one,a=1 s a=2 ss a=3 sss
     function paymentOne(uint a)public {
         uint n=OneNftOf[a][msg.sender];
         //读取NFT等级
         (uint256 a1,uint256 a2,uint256 a3,address nft)=getNFTlevel(a,n);
         //uint _nft=OneNftOf[a][msg.sender];
        require(getNftTime(a,n) > 0&& nftOwner[a][n] == msg.sender);
        ERC20(token).transfer(msg.sender,OrdersStop[100000000005]);//退回pcd
        makeAppointment[a][msg.sender]=false;
        Orders[msg.sender]=false;
        OrdersTime[a][n]=0;
        uint256 _pcd;
         address nftaddress;
        if(n <= NFTID[a]){
            nftaddress=NFTToken(nft).ownerOf(n);
            USDT.transferFrom(msg.sender,address(this),a1);//付款给
            USDT.transfer(nftaddress,a1.sub(a2));//卖方
           NFTToken(nft).transferFrom(nftaddress,msg.sender,n);
           OneNftOf[a][msg.sender]=0;
           nftOwner[a][n]=address(0);
           nfts[a][n].price=a1;
           //nfts[a][_nft].times=a3 + 1 days;
           nfts[a][n].addr=msg.sender;
           if(a2>0){
            _pcd=getEX(a2*2);//获得2%PCD
            ERC20(token).transfer(nftaddress,_pcd);
            users[nftaddress].Spcd+=_pcd;
            users[nftaddress].usdt+=a2*2;
           }
        }else{
           USDT.transferFrom(msg.sender,address(this),a1);//成功付款
           NFTID[a]++;//NFT增加
           NFTToken(nft).mint(msg.sender);
           OneNftOf[a][msg.sender]=0;
           nftOwner[a][n]=address(0);
           nfts[a][NFTID[a]].price=a1;
           nfts[a][NFTID[a]].addr=msg.sender;
           //nfts[a][NFTID[a]].times=a3 + 1 days;
        }
        address up1=users[nftaddress].upaddress;
        address up2=users[up1].upaddress;
        address up3=users[up2].upaddress;
        address up4=users[up3].upaddress;
        address up5=users[up4].upaddress;
        uint u;
        if(a2 >0){
           if(up1 != address(0)){
               sendPcd(up1,getEX(a2)*30/100);
               USDT.transfer(up1,a2*30/100);
           }else{
              u+=a2*30/100;
           }
           if(up2 != address(0)){
               sendPcd(up2,getEX(a2)*25/100);
               USDT.transfer(up2,a2*25/100);
           }else{
              u+=a2*25/100;
           }
           if(up3 != address(0)){
               sendPcd(up3,getEX(a2)*20/100);
               USDT.transfer(up1,a2*20/100);
           }else{
              u+=a2*20/100;
           }
           if(up4 != address(0)){
               sendPcd(up4,getEX(a2)*15/100);
               USDT.transfer(up1,a2*15/100);
           }else{
              u+=a2*15/100;
           }
           if(up5 != address(0)){
               sendPcd(up5,getEX(a2)*10/100);
               USDT.transfer(up1,a2*10/100);
           }else{
              u+=a2*10/100;
           }
           if(u>0){
               ERC20(usdtToken).transfer(0xf10F6F656Ca6fde4e78DC2cE70BEF35f056C7496,u);
           }
        }
     }
    function sendPcd(address addr,uint u)internal{
        ERC20(token).transfer(addr,u);
    }
    function getNftTime(uint a,uint nft) public view returns(uint){
        if(OrdersTime[a][nft] > block.timestamp){
            uint256 T=OrdersTime[a][nft] - block.timestamp;
            return T;
        }else{
            return 0;
        }
    }
    //1=s  2=ss 3=sss
    function getNFTlevel(uint256 a,uint n)public view returns(uint256,uint256,uint256,address){
        uint _price=nfts[a][n].price;
        uint ups;
        uint peicenft;
        //uint _time=nfts[a][n].times;
        if(a == 1){
           peicenft=priceOne;
        }else if(a ==2){
            peicenft=priceTwo;
        }else if(a ==3){
            peicenft=priceThree;
        }
        if(_price == 0){
         //peicenft=peicenft.mul(103).div(100);
         ups=0;
        }else{
            ups=_price.mul(103).div(100).sub(_price);
            peicenft=_price.mul(103).div(100);
        }
        if(a == 1){
            //S-NFT
            return (peicenft,ups.div(3),OrdersStop[1],tokens[10001]);
        }else if(a == 2){
            //SS-NFT
            return (peicenft,ups.div(3),OrdersStop[2],tokens[10002]);
        }else if(a == 3){
            //sss-NFT
            return (peicenft,ups.div(3),OrdersStop[3],tokens[10003]);
        }
    }
    function setnftSL(uint a,uint sl)public onlyOwner{
        OrdersTime[a][9999999999]=sl;
    }
    function getUserNFT(uint _a)public view returns(uint a,bool b,uint c,uint d,uint e,uint f,uint g,uint h,uint i,uint j){
        if(users[msg.sender].DirectP > block.timestamp){
          a=1;
        }else{
          a=0;
        }     
        b=false;
        if(_a == 1){
            c=priceOne;
        }
        if(_a == 2){
            c=priceTwo;
        }
        if(_a == 3){
            c=priceThree;
        }
        e=OrdersStop[100000000001];
        f=OrdersStop[100000000002];
        g=OrdersStop[100000000003];
        h=OrdersStop[1];
        i=OrdersStop[2];
        j=OrdersStop[3];
    }
    function getNftZt(uint a,address addr)public view returns(uint nn,uint vv,uint[] memory _nfts,uint b){
        uint n=OneNftOf[a][addr];
        uint peicenft;
        _nfts=users[addr].nfts;
        b=users[addr].nfts.length;
        if(a == 1){
           peicenft=priceOne;
        }else if(a ==2){
            peicenft=priceTwo;
        }else if(a ==3){
            peicenft=priceThree;
        }
        vv=peicenft*103/100;
        uint dayNfts;
         if(a==1){
            dayNfts=OrdersStop[100000000001]; 
         }
         if(a==2){
             dayNfts=OrdersStop[100000000002];
         }
         if(a==3){
             dayNfts=OrdersStop[100000000003];
         }
         uint oknft=OrdersTime[a][9999999999];//最多只能抢预约总量的80%
        if(!activation[addr]){
            nn=0;//请激活
        }else if(activation[addr]){
            nn=1;//已激活
        }
        if(!makeAppointment[a][addr] && DirectPushTime[a][addr] < block.timestamp && nn==1){
          nn=2;//请预约
        }else{
          if(makeAppointment[a][addr]){
            nn=3;//抢拍
          }
        }
        if(OneNftOf[a][addr] > 0){
          nn=4;//请付款
        }
        if(oknft <= dayNfts){
          nn=5;//已抢完
        }
        if(DirectPushTime[a][addr] > block.timestamp && OneNftOf[a][addr]==0 && oknft <= dayNfts){
          nn=6;//明天再抢
        }

    }
    function getuP(address addr)public view returns(uint){
        return users[addr].bz;
    }
    function getUser(address addr)public view returns(address[] memory adds, uint a,uint b,uint c,uint d,uint e){
        adds=users[addr].taem;
        a=users[addr].usdt;//累计收益USDT
        b=users[addr].Spcd;//累计收益PCD
        c=users[addr].OKpcd;//累计释放
        d=users[addr].pcd;//累计锁仓PCD
        e=getDayPcd(addr);//待释放
    }
    receive() external payable {}
}