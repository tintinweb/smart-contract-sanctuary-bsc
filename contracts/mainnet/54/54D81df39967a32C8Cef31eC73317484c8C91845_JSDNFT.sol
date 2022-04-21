/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

pragma solidity >=0.6.0 <0.8.0;
 interface ERC20 {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver)external returns(uint256);
    function getTeam(address addr)external view returns(address);
}
interface NFTToken{
    function ownerOf(uint256 _tokenId) external view returns (address);
    function transferFrom(address _from, address _to, uint256 _value)external;
    function mint(address toAddress)external;
    function balanceOf(address _owner) external view returns (uint256);
    function getUserPower(address addr)external view returns(uint);//个人算力
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
interface Foundations {
    function sendDistribution(uint256 _value)external;
}
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}
contract JSDNFT{
    using SafeMath for uint256;
    address public owner;
    uint256 public priceOne;//NFT价格
    uint256 public priceTwo;//NFT价格
    uint256 public priceThree;//NFT价格
    uint256 public stopTime;
    mapping(uint256 => uint256) public NFTID;
    ERC20 public USDT;
    ERC20 public JSDToken;
    NFTToken public NFTTokens;
    mapping(uint256 => mapping(address => uint256)) public OneNftOf;
    mapping(uint => mapping(uint => address)) public nftOwner;//被谁抢到
    mapping(address => bool) public activation;//激活钱包
    mapping(uint =>mapping(address => bool)) public makeAppointment;//预约抢单
    mapping(address => bool) public Orders;//抢单是否成功
    mapping(uint256 =>mapping(uint256 =>uint)) public OrdersTime;//支付倒计时
    mapping(uint => uint) public OrdersStop;//抢单结束时间1小时，开始时间11：30   15：30   19：30
    mapping(uint =>mapping(uint =>bool)) public lock;//是否收藏
    mapping(address =>user) public users;
    mapping(uint => address)public tokens;
    mapping(uint =>mapping(uint => NFTT)) public nfts;
    mapping(uint256 => mapping(address => uint256)) public teamLevel;
    uint256 mnus;
    struct user{
        address upAddress;
        uint256 level;
        uint256 Number;
        uint256 shouyi;
        uint256 DirectPushTime;
        uint256 yeji;
        uint256 profit;
        uint256 power;
        uint256 team;
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
         USDT=ERC20(0x55d398326f99059fF775485246999027B3197955);//USDT合约地址
         JSDToken=ERC20(tokens[1]);//JSD代币
         OrdersStop[1]=1651289400;//4-30 11:30
         //OrdersStop[1]=block.timestamp+60;//4-30 11:30
         OrdersStop[2]=1651303800;//4-30 15:30
         OrdersStop[3]=1651318200;//4-30 19:30
         NFTTokens=NFTToken(tokens[3]);//算力挖矿合约地址
         NFTID[1]=1;
         NFTID[2]=1;
         NFTID[3]=1;
         priceOne=100 ether;
         priceTwo= 200 ether;
         priceThree= 500 ether;
        stopTime=1650384000;//每天24点
     }
     function setTokens(address addr,uint a)public onlyOwner{
         tokens[a]=addr;
         //1=JSD代币，2=基金会，3=算力挖
     }
     function setTokensg()public onlyOwner{
         NFTTokens=NFTToken(tokens[3]);//算力挖矿合约地址
         JSDToken=ERC20(tokens[1]);//JSD代币
         //1=JSD代币，2=基金会，3=算力挖
     }
     //24：00上涨3%
     function setPrice()internal{
         if(block.timestamp > stopTime){
         stopTime+= 1 days;
         OrdersStop[1]+=1 days;
         OrdersStop[2]+=1 days;
         OrdersStop[3]+=1 days;
         }       
     }
     //点击收藏a= s=1ss=2sss=3
     function setCollection(uint a,uint _n)public{
         //读取NFT等级
         (uint256 a1,uint256 a2,uint256 a3,address nft)=getNFTlevel(a,_n);
         require(NFTToken(nft).ownerOf(_n) == msg.sender);
         lock[a][_n]=true;
         nfts[a][_n].price=a1;
         nfts[a][_n].addr=msg.sender;
     }
     //支付1U 代币激活账户
     function setUsdt(address addr,uint JSD)public{
         require(!activation[msg.sender]);
         user storage _fall=users[msg.sender];
         //支付1U价值代币激活账户
        JSDToken.transferFrom(msg.sender,0x68F34AE3351816F455d5D008b7B83e1F65C5DC29,JSD);
        activation[msg.sender]=true;
        //绑定上下级关系
        address upaddr=JSDToken.getTeam(msg.sender);
        if(upaddr !=address(0) && users[msg.sender].upAddress == address(0)){
            _fall.upAddress=upaddr;
            users[upaddr].Number++;
        }else if(users[msg.sender].upAddress == address(0)){
            _fall.upAddress=addr;
            users[addr].Number++;
        }
     }
    function _team(address to)internal{
         if(users[to].level == 3 && users[to].power > getProfit(to,10000,10000 ether)){        
            if(teamLevel[4][to] ==0 && teamLevel[3][to] >=4){
             users[to].level=4;   
            _updateTeamLevel(to,4);
            PeerBonus(to,4);
            shoyizhix(to,40);
            }
          }else if(users[to].level == 2 && users[to].power > getProfit(to,1000,5000 ether)){
            if(teamLevel[3][to] ==0 && teamLevel[2][to] >=4){
             users[to].level=3;
            _updateTeamLevel(to,3);
            PeerBonus(to,3);
            shoyizhix(to,30);
            }
          }else if(users[to].level == 1 && users[to].power > getProfit(to,100,500 ether)){
            if(teamLevel[2][to] ==0 && teamLevel[1][to] >=4){
            users[to].level=2;
            _updateTeamLevel(to,2);
            PeerBonus(to,2);
            shoyizhix(to,20);
            }
          }else if(users[to].yeji == 10000 ether){
            if(teamLevel[1][to] ==0){
            users[to].level=1;
            _updateTeamLevel(to,1);
            shoyizhix(to,10);
            }
        }
    }
    function shoyizhix(address to,uint b)internal{
        if(users[to].shouyi > 0){
            USDT.transfer(to,users[to].shouyi * b / 100);
            users[to].profit+=users[to].shouyi *b / 100;
            users[to].shouyi=0;
        }
    }
    function getProfit(address to,uint256 kh,uint256 _power)public view returns(uint256){
        uint256 power;
        uint256 s;
        if(users[to].profit > _power){
            s=users[to].profit.div(_power);
            power=s.mul(_power);
        }else{
            power=kh;
        }
        return power;
    }
    //平级奖金
    function PeerBonus(address addr,uint L)public{
         address upaddr=addr;
         uint rs=0;
        for(uint i=0;i < 16;i++){ 
            if(users[upaddr].upAddress != address(0)){       
               if(users[upaddr].level == L){
                rs++;
                if(rs==2){
                    USDT.transfer(upaddr,users[upaddr].shouyi *10 / 100);
                    users[upaddr].profit+=users[upaddr].shouyi *10 / 100;
                    users[upaddr].shouyi=0;
                }
               }
            upaddr=users[upaddr].upAddress;
            }else{
                break;
            }
        }
    }
    function _updateTeamLevel(address addr,uint256 L)internal{
        address upaddr=addr;
        for(uint i=0;i < 16;i++){          
            if(users[upaddr].upAddress != address(0)){
                  teamLevel[L][upaddr]++;
                  upaddr=users[upaddr].upAddress;  
            }else{
                break;
            }
        }
    }
     //支付10U预约抢购,a=1 s a=2 ss a=3 sss
     function Appointment(uint256 a,uint n)public {
         //读取NFT等级
         (uint256 a1,uint256 a2,uint256 a3,address nft)=getNFTlevel(a,n);
         require(!makeAppointment[a][msg.sender] && activation[msg.sender] && users[msg.sender].DirectPushTime < a3);
         USDT.transferFrom(msg.sender,address(this),10 ether);
         makeAppointment[a][msg.sender]=true;//预约成功
         users[msg.sender].power=NFTTokens.getUserPower(msg.sender) * 1 ether;
     }
     //抢单,a=1 s a=2 ss a=3 sss
     function GrabOrders(uint256 a,uint n)public{
         //读取NFT等级
         (uint256 a1,uint256 a2,uint256 a3,address nft)=getNFTlevel(a,n);
        require(block.timestamp > nfts[a][n].times);
         require(block.timestamp > a3);
         require(makeAppointment[a][msg.sender] && users[msg.sender].DirectPushTime < a3);
         require(!lock[a][n]);
          mnus+=9;
          uint256 mnu=random(mnus);
          if(mnu > 40){
             OrdersTime[a][n]=block.timestamp + 3600;
             users[msg.sender].DirectPushTime=a3;
             Orders[msg.sender]=true;
             nftOwner[a][n]=msg.sender;//暂时被我抢到
             makeAppointment[a][msg.sender]=false;
             OneNftOf[a][msg.sender]=n;
          }else{
             users[msg.sender].DirectPushTime=a3;
             makeAppointment[a][msg.sender]=false;
             USDT.transfer(msg.sender,10 ether);
             OrdersTime[a][n]=1;
          }
     }
     //付款one,a=1 s a=2 ss a=3 sss
     function paymentOne(uint a,uint n)public {
         //读取NFT等级
         (uint256 a1,uint256 a2,uint256 a3,address nft)=getNFTlevel(a,n);
         uint _nft=OneNftOf[a][msg.sender];
         require(_nft > 0);
        require(getNftTime(a,_nft) > 0 && !lock[a][_nft] && nftOwner[a][_nft] == msg.sender);
        USDT.transfer(msg.sender,10 ether);//退回10U
        makeAppointment[a][msg.sender]=false;
        user storage _user=users[msg.sender];
        Orders[msg.sender]=false;
        address _fall=_user.upAddress;
        OrdersTime[a][_nft]=0;
        if(_nft <= NFTID[a]){
         USDT.transferFrom(msg.sender,NFTToken(nft).ownerOf(_nft),a1.sub(a2 *2));//成功付款给原来持有者
            //从别人手里抢过来
           NFTToken(nft).transferFrom(NFTToken(nft).ownerOf(_nft),msg.sender,_nft);
           nftOwner[a][n]=address(0);
           if(nfts[a][_nft].price==0){
           nfts[a][_nft].price=a1;
           nfts[a][_nft].times=stopTime;
           }
           nfts[a][_nft].addr=msg.sender;
        }else{
        USDT.transferFrom(msg.sender,address(this),a1);//成功付款
        USDT.transfer(tokens[6],a1*3/100);
         //铸造NFT
         NFTID[a]++;//NFT增加
         NFTToken(nft).mint(msg.sender);
         nftOwner[a][n]=address(0);
         nfts[a][NFTID[a]].price=a1;
         nfts[a][NFTID[a]].addr=msg.sender;
         nfts[a][NFTID[a]].times=stopTime;
        }      
        //动态奖金+基金会 OrdersStop[13]OrdersStop[14]OrdersStop[15]
        if(a2 >0){
           USDT.transfer(tokens[2],a2);//基金会1%
        }
        //OrdersStop[16]作为动态奖金池子累计
        if(_fall !=address(0) && a2 >0){
            //直推10%
            USDT.transfer(_fall,a2.mul(10).div(100));
        }
        _user.yeji+=a1;
        address ad=msg.sender;
        for(uint i=0;i < 16;i++){
            if(users[ad].upAddress != address(0)){
                users[users[ad].upAddress].team++;
                _team(users[ad].upAddress);
                users[users[ad].upAddress].yeji +=a1;
                users[users[ad].upAddress].shouyi+=a2;
            }else{
              break;
            }
            ad=users[ad].upAddress;
        }
        //OrdersStop[16]=OrdersStop[16].add(OrdersStop[13]);
        //NoPayment();
     }
     //检查所有当日NFT有没有未付款的NFT,a=1 s a=2 ss a=3 sss
     function NoPayment(uint256 a,uint n)public{
         setPrice();
         //读取NFT等级
         (uint256 a1,uint256 a2,uint256 a3,address nft)=getNFTlevel(a,n);
         address addr;
         for(uint i=1;i < NFTID[a];i++){
            if(OrdersTime[a][i] > 10 && OrdersTime[a][i] < block.timestamp){
                //这NFT 1小时内没有付款
                addr=NFTToken(nft).ownerOf(i);
                //发送给出售方5U
                USDT.transfer(addr,5 ether);
                OrdersTime[a][i]=1;
                //5U进入博饼池子购买币直接进入黑洞
                address[] memory path;
                path[0]=0x55d398326f99059fF775485246999027B3197955;
                path[1]=tokens[1];//JSD代币
                IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E).swapExactTokensForTokens(5 ether,100,path,0x000000000000000000000000000000000000dEaD,block.timestamp + 360);
                Foundations(tokens[2]).sendDistribution(5000 ether);
            }
         }
     }
    //检查NFT价格是否大于等于200，S级升级SS
    function vaifenS()public{
        setPrice();
        (,,,address nftss)=getNFTlevel(1,1);
        for(uint k=1;k< NFTToken(nftss).tokenNextId()-1;k++){
           if(nfts[1][k].price >=200 ether){
               updateOneNFT(NFTToken(nftss).ownerOf(k),2,k,priceTwo,200 ether);
           }
        }
    }
    //检查NFT价格是否大于等于500，SS级升级SSS
    function vaifenSS()public{
        setPrice();
        (,,,address nftss)=getNFTlevel(2,1);
        for(uint k=1;k< NFTToken(nftss).tokenNextId()-1;k++){
           if(nfts[2][k].price >=500 ether){
               updateOneNFT(NFTToken(nftss).ownerOf(k),3,k,priceThree,500 ether);
           }
        }
    }
     //检查NFT价格是否大于等于1500，拆分
    function vaifenSSS()public{
        (,,,address nftss)=getNFTlevel(3,1);
        for(uint k=1;k< NFTToken(nftss).tokenNextId()-1;k++){
           if(nfts[3][k].price >=1500 ether){
               backNFT(NFTToken(nftss).ownerOf(k),nftss,k);
           }
        }
    }
    function backNFT(address addr,address nftss,uint i)internal{
         //销毁没收藏的NFT
         //铸造NFT--4个S级
         for(uint h=0;h<4;h++){
            NFTID[1]++;//NFT增加
            NFTToken(0xEd59Bd702c581BdA60C360B53206F0238a9B6F09).mint(addr);
            nfts[1][NFTID[1]].price=priceOne;
            nfts[1][NFTID[1]].addr=msg.sender;
            nfts[1][NFTID[1]].times=stopTime;
        }
        //铸造NFT--3个 SS级
        for(uint k=0;k<3;k++){
            NFTID[2]++;//NFT增加
            NFTToken(0x1b2bD14F24B6B5176182c853bb73ce9229b57E7d).mint(addr);
            nfts[2][NFTID[2]].price=priceTwo;
            nfts[2][NFTID[2]].addr=msg.sender;
            nfts[2][NFTID[2]].times=stopTime;
        }
        //铸造1个 SSS级
            NFTID[3]++;//NFT增加
            NFTToken(nftss).mint(addr);
            nfts[3][NFTID[3]].price=priceThree +_getheer(3,i,1500 ether);//增加SSS价格超过1500的部分给新的SSS级 500 +超出部分金额
            nfts[3][NFTID[3]].addr=msg.sender;
            nfts[3][NFTID[3]].times=stopTime;
    }
    function updateOneNFT(address addr,uint a,uint i,uint _price,uint b)internal{
       (,,,address nftss)=getNFTlevel(a,1);
       NFTToken(nftss).mint(addr);
       NFTID[a]++;//NFT增加
       nfts[a][NFTID[a]].price=_price +_getheer(2,i,b);//增加SSS价格超过1500的部分给新的SSS级 500 +超出部分金额
       nfts[a][NFTID[a]].addr=msg.sender;
       nfts[a][NFTID[a]].times=stopTime;
    }
    function _getheer(uint a,uint n,uint _v)public view returns(uint){
        uint val;
        if(nfts[a][n].price > _v){
           val=nfts[a][n].price - _v;
        }else{
            val=0;
        }
        return val;
    }
    function random(uint256 randomyType) public view returns(uint) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp,randomyType)));
        uint AAA=random % 99;
        if(AAA > 99){
            AAA=99;
        }       
        return AAA;
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
        uint up=_price;
        uint peicenft;
        uint _time=nfts[a][n].times;
        if(a ==1){
           peicenft=priceOne;
        }else if(a ==2){
            peicenft=priceTwo;
        }else if(a ==3){
            peicenft=priceThree;
        }
        if(_time == 0){
            _price=peicenft;
        }else if(block.timestamp > _time){
            _price=_price.mul(103).div(100);
            up=_price.sub(up);
        }
        if(a == 1){
            //S-NFT
            return (_price,up.div(3),OrdersStop[1],0xEd59Bd702c581BdA60C360B53206F0238a9B6F09);
        }else if(a == 2){
            //SS-NFT
            return (_price,up.div(3),OrdersStop[2],0x1b2bD14F24B6B5176182c853bb73ce9229b57E7d);
        }else if(a == 3){
            //sss-NFT
            return (_price,up.div(3),OrdersStop[3],0x729A1007dF175b97A0fb83EAa53f237db64C140f);
        }
    }
    function getUsdt(address addr,uint _value)public onlyOwner{
        USDT.transfer(addr,_value);
    }
    function getNftLoc(uint a,uint nft) public view returns(bool){
            return lock[a][nft];
    }
    function getNftLock(uint nft) public view returns(bool){
            return true;
    }
    function _nftOwner(uint a,uint nft) public view returns(address){
        return nftOwner[a][nft];
    }
    function getUserNFT(uint _a,uint nft)public view returns(address a,bool b,uint c,uint d){
        a=_nftOwner(_a,nft);//谁抢到
        b=getNftLoc(_a,nft);//是否收藏
        (c,d,,)=getNFTlevel(_a,nft);//NFT价格 d=抢拍时间
    }
    function getUser(address addr)public view returns(address a,uint b,uint c,uint d,uint e,uint f,uint i,uint j,uint k){
        a=users[addr].upAddress;//上级
        b=users[addr].level;//V1 团队等级
        c=users[addr].Number;//直推人数
        d=users[addr].shouyi;//收益
        e=users[addr].DirectPushTime;//预约时间
        f=users[addr].yeji;//业绩
        i=users[addr].profit;//已经收益
        j=users[addr].power;//算力
        k=users[addr].team;//团队人数
    }
    receive() external payable {}
}