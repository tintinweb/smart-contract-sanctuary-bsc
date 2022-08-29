// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.6.0;
import "./SafeMath.sol";
import "./ReentrancyGuard.sol";
import "./TransferHelper.sol";
import "./IBEP20.sol";
import "./Ownable.sol";

interface ILizMiner
{
    function getParent(address user) external view returns (address);
    function getOneshareNow() external view returns (uint256);
    function fixUserInfo(address user,uint idx,uint256  val) external;
    function getUserInfo(address user,uint idx) external view returns (uint256);
    function WithDrawCredit() external;
}

interface IOldMiner {
    function getPendingLIZ(address user) external view returns (uint256);
    function getUserSelfLizhash(address user) external view returns(uint256);
    function MappingUserFromOld(address user) external;
    function _baseLibHash(address user) external view returns (uint256);
    function _outedhash(address user) external view returns (uint256);
    function _takedlib(address user) external view returns (uint256);
    function _pendinglib(address user) external view returns (uint256);
    function _takeddt(address user) external view returns (uint256);
    function _totaldt(address user) external view returns (uint256);
    function _invitecount(address user) external view returns (uint256);
    function _extendLibhash(address user) external view returns (uint256);
    function _stackLit(address user) external view returns (uint256);
    function _pendingliz(address user) external view returns (uint256);
    function _takedliz(address user) external view returns (uint256);
    function _extendedlizhash(address user) external view returns (uint256);
    
    function TotalPower() external view returns (uint256);
    function Libprice() external view returns (uint256);
    function oneshareLib() external view returns (uint256);
    function _lastcheckpoint() external view returns (uint256);
    function getPendingLizDT(address user) external view returns (uint256);
    function getInviteCount(address user) external view returns(uint256);
    function takedLib(address user) external view returns(uint256);
    function pendingLib(address user) external view returns(uint256);
    function getOneshareNow() external view returns (uint256);
    function getUserSelfHash(address user) external view returns (uint256);
    function getAddedBasePower(address user) external view returns (uint256);
 
}

interface IIEO
{
    function getUserIEOAmount(address user) external view returns (uint256);
}
  
interface IPancakePair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

interface IBOXNEW
{
    function FixLizHash(uint256 amount,bool add) external;
    function AddCreditD(uint256 amount) external;
}

interface IPancakeRouter{

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

}


contract LIZSMinerV3 is Ownable,ReentrancyGuard 
{

    mapping(address=>bool) _mapped;
    ILizMiner _lizminer;
    IOldMiner _oldminer;
    IBOXNEW _boxnew;
    address _litminera;

    mapping(address=>uint256) public _baseLibHash;
    mapping(address=>uint256) public _outedhash;
    mapping(address=>uint256) public _takedlib;
    mapping(address=>uint256) public _pendinglib;
    mapping(address=>uint256) public _takeddt;
    mapping(address=>uint256) public _totaldt;
    mapping(address=>uint256) public _invitecount;
    mapping(address=>uint256) public _extendLibhash;
    mapping(address=>uint256) public _stackLit;
    mapping(address=>uint256) public _pendingliz;
    mapping(address=>uint256) public _takedliz;
    mapping(address=>uint256) public _extendedlizhash;

    using SafeMath for uint256;
    using TransferHelper for address;

    uint256 immutable cs = 1e39;
    uint256 _xs;
    address  _mulladdress;
    address  _libtrade;
    address  _libaddr;
    address  _lizaddr;
    address  _liztrade;
    address  _usdtaddress;
    address  _router;
  
    uint256 extendpowerrate;
    uint256 public TotalPower;
    uint256 public Libprice;
    uint256 public oneshareLib;
    uint256 public _lastcheckpoint;
 
    address _littrade;
    address _litaddress;
    address public _liblppool;
    IIEO _ieo;
 
    constructor(address router,address ieo)
    {
        _router=router;
        _xs=2000 * 1e8;
        _ieo=IIEO(ieo);
        extendpowerrate=15;
    }

    function setTradeAddress(address mull,address libtrade,address libaddr,address lizaddr,address liztrade,address usdtaddress,address liblppool) public onlyOwner
    {
        _mulladdress=mull;
        _libtrade=libtrade;
        _libaddr=libaddr;
        _lizaddr=lizaddr;
        _liztrade=liztrade;
        _usdtaddress=usdtaddress;
        _liblppool=liblppool;
        IBEP20(_usdtaddress).approve(address(_router),1e40);
    }

    function setExtendPowerRate(uint256 amount) public onlyOwner 
    {
        oneshareLib= getOneshareNow();
        _lastcheckpoint=block.number;
        extendpowerrate=amount;
    }
 
    function setAddress(address lizminer,address oldminer,address boxnew,address littrade,address litaddress,address litminera) public onlyOwner
    {
        _lizminer=ILizMiner(lizminer);
        _oldminer = IOldMiner(oldminer);
        _boxnew = IBOXNEW(boxnew);
        _littrade= littrade;
        _litaddress= litaddress;
        Libprice= _oldminer.Libprice();
        TotalPower=_oldminer.TotalPower();
        oneshareLib= _oldminer.getOneshareNow();
        _lastcheckpoint=block.number;
        _litminera=litminera;
    }
 
    function MappingUserFromOld(address user) public
    {
        if(_mapped[user])
            return;
        _oldminer.MappingUserFromOld(user);
        _pendingliz[user]=_oldminer._pendingliz(user);
        _takedliz[user] = _oldminer._takedliz(user);
        _baseLibHash[user]= _oldminer._baseLibHash(user);
        _outedhash[user]= _oldminer._outedhash(user);
        _takedlib[user] = _oldminer._takedlib(user);
        _pendinglib[user] = _oldminer._pendinglib(user);
        _takeddt[user] = _oldminer._takeddt(user);
        _totaldt[user] = _oldminer._totaldt(user);
        if(_invitecount[user]==0)
            _invitecount[user] = _oldminer._invitecount(user);
        _extendedlizhash[user]=_oldminer._extendedlizhash(user);
        _extendLibhash[user] = _oldminer._extendLibhash(user);
        _mapped[user] =true;
    }

    function _takedlizA(address user) public view returns(uint256)
    {
        if(_mapped[user])
            return _takedliz[user];
        else
            return _oldminer._takedliz(user);
    }

    //base power
    function getUserSelfHash(address user) public view returns (uint256)
    {
        if(_mapped[user])
            return _baseLibHash[user].add(_ieo.getUserIEOAmount(user).mul(2)).subwithlesszero(_outedhash[user]);
        else 
        {
            return _oldminer.getUserSelfHash(user);
        }
    }

    function getInviteCount(address user) public view returns(uint256)
    {
         if(_mapped[user])
            return _invitecount[user];
        else
            return _oldminer.getInviteCount(user);
    }

    function getOneUsdtToCoin(address tradeaddr) public view returns (uint256)
    {
        (uint112 _reserve0, uint112 _reserve1, ) =IPancakePair(tradeaddr).getReserves();
        if(IPancakePair(tradeaddr).token0() == _usdtaddress)
        {
            uint256 a= _reserve0;
            uint256 b = _reserve1;
            return b.mul(1e18).div(a);
        }
        else
        {
            uint256 a= _reserve0;
            uint256 b = _reserve1;
            return a.mul(1e18).div(b);
        }
    }

    function getOneCoinToUsdt(address tradeaddr,uint decimals) public view returns (uint256)
    {
        (uint112 _reserve0, uint112 _reserve1, ) =IPancakePair(tradeaddr).getReserves();
        if(IPancakePair(tradeaddr).token0() == _usdtaddress)
        {
            uint256 a= _reserve0;
            uint256 b = _reserve1;
            return a.mul(10 ** decimals).div(b);
        }
        else
        {
            uint256 a= _reserve0;
            uint256 b = _reserve1;
            return b.mul(10 ** decimals).div(a);
        }
    }

    function getOneshareNow() public view returns (uint256)
    {
         uint256 o=oneshareLib;
         if(block.number > _lastcheckpoint)
         {
            o= o.add(cs.div(TotalPower).mul(block.number.sub(_lastcheckpoint)));
         }
         return o;
    }

    function userDtChanged(address user,uint256 oneamount,uint256 idx) private returns (uint256)
    {
        uint256 hashval= 8e18;
        uint256 userhash = getUserSelfHash(user);
        if(userhash < hashval)
            return 0;
        if(getInviteCount(user) <idx)
            return 0;
        MappingUserFromOld(user);
        _pendingliz[user]=getPendingLIZ(user);
        _takedliz[user] = _lizminer.getOneshareNow();
        _totaldt[user] = _totaldt[user].add(oneamount);
        outUserHash(user,hashval.div(3),false);
        return hashval.div(3);
    }

    function outUserHash(address user,uint256 shash,bool add) private
    {
        BaseHashChanged(user, shash, add);
        LogCheckPoint(shash, add);
    }

    function getTotalLIBPower(address user) public view returns (uint256)
    {
        uint256 myhash=getUserSelfHash(user).add(getAddedBasePower(user).mul(extendpowerrate));
        return myhash;
    }

    function getUserSelfLizhash(address user) public view returns(uint256)
    {
        uint256 currenthash=0;
        if(_mapped[user])
        {
            currenthash= _extendedlizhash[user];
            return currenthash.add(getTotalLIBPower(user));
        }   
        else
            return _oldminer.getUserSelfLizhash(user);
    }

    function AddExtendHash(uint256 amount) public 
    { 
        require(amount% _xs ==0,'error amount');
        address user=msg.sender;
        MappingUserFromOld(user);
        _mulladdress.safeTransferFrom(user, address(this), amount);
        if(getUserSelfHash(user) > 0)
            _pendingliz[user]=getPendingLIZ(user);
        _takedliz[user] = _lizminer.getOneshareNow();
        uint256 addhash=amount.div(_xs).mul(240*1e18);
        _extendedlizhash[user] = _extendedlizhash[user].add(addhash);
        _boxnew.FixLizHash(addhash, true);
    }

    function getPendingLizDT(address user) public view returns (uint256)
    {
        if(_mapped[user]==false)
            return _oldminer.getPendingLizDT(user);
        else
            return _totaldt[user].subwithlesszero(_takeddt[user]);
    }

    function takeOutErrorTransfer(address tokenaddress,address target,uint256 amount) public onlyOwner
    {
        IBEP20(tokenaddress).transfer(target,amount);
    }

    function getPendingLIZ(address user) public view returns (uint256)
    {
        if(!_mapped[user])
            return _oldminer.getPendingLIZ(user);
            
        uint256 myhash=getUserSelfLizhash(user);
        uint256 oc=_lizminer.getOneshareNow();
        if(myhash>0)
        {
            uint256 cashed=_takedlizA(user);
            if(cashed==0)
                return _pendingliz[user];
            uint256 newp =0;
            newp = myhash.mul(oc.subwithlesszero(cashed)).div(1e32);
            return _pendingliz[user].add(newp);
        }
        else
        {
            return _pendingliz[user];
        }
    }


     function AddMinePower(uint256 amount) public
    {   
        require(amount >= 1e20 ,"min");
        address user = msg.sender;
        MappingUserFromOld(user);
        _usdtaddress.safeTransferFrom(user, address(this), amount);
         uint256 oneu=getOneUsdtToCoin(_liztrade);
         uint256 payliz = amount.mul(oneu).div(1e18);
         _lizaddr.safeTransferFrom(user, address(this), payliz);
         uint256 selfhash=amount.mul(2);

        address[] memory path1=new address[](2);
        path1[0]= _usdtaddress;
        path1[1]= _libaddr;
       
        uint256 deadline=block.timestamp + 86400;
        uint[] memory amounts =IPancakeRouter(_router).swapExactTokensForTokens(IBEP20(_usdtaddress).balanceOf(address(this)), 0, path1, address(this),deadline);
        IBEP20(_libaddr).burn(amounts[1]);
 
         uint256 onedt = oneu.mul(8);
         address parent = user;
         uint256 givedcount=0;
         uint256 totaldecpower=0;
        for(uint256 i=0;i<20;i++)
        {
            parent= _lizminer.getParent(parent);
            if(parent==address(0))
                break;
 
            uint256 gived=userDtChanged(parent,onedt,givedcount+1);
             
            if(gived>0)
            {
                totaldecpower += gived;
                givedcount++;
                if(givedcount>=9)
                    break;
            }
        }
        _lizaddr.safeTransfer(address(0xdead), payliz.subwithlesszero(onedt.mul(10)));
        if(getUserSelfHash(user) > 0)
            _pendingliz[user]=getPendingLIZ(user);

        _takedliz[user] = _lizminer.getOneshareNow();
        outUserHash(user, selfhash, true);
    }

     function ShowDecreaseHash(address user) public view returns(uint256[2] memory)
    {
        uint256[2] memory ret;
         uint256 givelib= getPendingLIZS(user);
         uint256 jtliz=getPendingLIZ(user);
         uint256 lizprice=getOneCoinToUsdt(_liztrade,8);

         uint256 decreasehash=givelib.mul(Libprice).div(3e8);
         decreasehash +=jtliz.mul(lizprice).div(3e8);

         uint256 libhash=getUserSelfHash(user);
        uint256 extendhash = _mapped[user] ?_extendedlizhash[user] : _oldminer.getUserSelfLizhash(user).subwithlesszero(getUserSelfHash(user));
        if(decreasehash < libhash)
        {
            ret[0]= decreasehash;
            ret[1]=extendhash.mul(decreasehash).div(libhash).add(decreasehash);
        }
        else{
            ret[0]= libhash;
            ret[1]=extendhash.add(libhash);
        }
        return ret;
    }

    function UpdatePrice() public
    {
        Libprice= getOneCoinToUsdt(_libtrade,8);
    }
 
    function WithDrawCredit() public nonReentrant returns (bool) 
    {
        address user= msg.sender;
        UpdatePrice();
        MappingUserFromOld(user);
         uint256 givelib= getPendingLIZS(user);
         uint256 giveliz=getPendingLIZ(user);
         uint256 lizprice=getOneCoinToUsdt(_liztrade,8);
 
         uint256 decreasehash=givelib.mul(Libprice).div(3e8);
         decreasehash +=giveliz.mul(lizprice).div(3e8);

         if(decreasehash==0)
            return true;

         uint256 libhash= getUserSelfHash(user) + _extendLibhash[user];

         if(decreasehash < libhash)
           { 
               uint256 subhash=_extendedlizhash[user].mul(decreasehash).div(libhash);
               _extendedlizhash[user]=_extendedlizhash[user].subwithlesszero(subhash);
               outUserHash(user,decreasehash , false);
          }
          else
          {
              giveliz = giveliz.mul(libhash).div(decreasehash);
              givelib = givelib.mul(libhash).div(decreasehash);
              _extendedlizhash[user]=0;
              outUserHash(user,libhash , false);
          }

          if(_totaldt[user] > _takeddt[user])
             giveliz += _totaldt[user].sub(_takeddt[user]);

          if(giveliz > 0)
            _lizaddr.safeTransfer(user, giveliz);

          if(givelib > 0)
         {
             _libaddr.safeTransfer(user, givelib);
         }

        _takedliz[user] = _lizminer.getOneshareNow();
        _pendingliz[user]=0;
        _takedlib[user]= getOneshareNow();
        _pendinglib[user]=0;
        _takeddt[user] = _totaldt[user];
        return true;
    }

    function takedLib(address user) public view returns(uint256)
    {
        if(_mapped[user])
            return _takedlib[user];
        else
            return _oldminer.takedLib(user);
    }

    function pendingLib(address user) public view returns(uint256)
    {
        if(_mapped[user])
            return _pendinglib[user];
        else
            return _oldminer.pendingLib(user);
    }


    function getPendingLIZS(address user) public view returns (uint256)
    {
       uint256 myhash=getUserSelfHash(user).add(getAddedBasePower(user).mul(extendpowerrate));
       if(myhash>0)
       {
            uint256 oneshare=getOneshareNow();
            uint256 cashed=takedLib(user);
            uint256 newp =0;
            if(oneshare > cashed)
               newp = myhash.mul(oneshare.subwithlesszero(cashed)).div(1e32);
            return pendingLib(user).add(newp);
        }
        else
        {
            return pendingLib(user);
        }
    }

    function LogCheckPoint(uint256 totalhashdiff,bool add) private
    {
 
        if(block.number > _lastcheckpoint)
        {
            Libprice= getOneCoinToUsdt(_libtrade,8);
            uint256 addoneshar= cs.div(TotalPower).mul(block.number.sub(_lastcheckpoint));
            oneshareLib = oneshareLib.add(addoneshar);
            _lastcheckpoint= block.number;
        }

        if (add) {
            TotalPower = TotalPower.add(totalhashdiff);
        } else {
            TotalPower = TotalPower.subwithlesszero(totalhashdiff);
        }
    }
 
    function BaseHashChanged(
        address user,
        uint256 selfhash,
        bool add
    ) private {
        uint256 phash = getUserSelfHash(user);
        if(phash>0)
        {
            _pendinglib[user]= getPendingLIZS(user);
        }
        _takedlib[user]=getOneshareNow();
        if (selfhash > 0) {
            if (add) {
                if(phash==0)
                {
                    address parent = _lizminer.getParent(user);
                    _invitecount[parent] = getInviteCount(parent) + 1;
                }
                _baseLibHash[user] = _baseLibHash[user].add(selfhash);
            } else
                if(_extendLibhash[user] >= selfhash.div(2))
                {
                    _extendLibhash[user]= _extendLibhash[user].subwithlesszero(selfhash.div(2));
                    _outedhash[user] = _outedhash[user].add(selfhash.div(2));
                }
                else
                {
                    selfhash = selfhash.subwithlesszero(_extendLibhash[user]);
                    _extendLibhash[user]=0;
                    _outedhash[user] = _outedhash[user].add(selfhash);
                }

               if( getUserSelfHash(user) ==0)
               {
                   address parent = _lizminer.getParent(user);
                   _invitecount[parent] =getInviteCount(parent).subwithlesszero(1);
               }
        }
    }
 
    function getAddedBasePower(address user) public view returns (uint256)
    {
        if(_mapped[user])
            return _extendLibhash[user];
        else
            return _oldminer.getAddedBasePower(user);
    } 

    function getAddedRate(address user) public view returns (uint256)
    {
        return getAddedBasePower(user).mul(extendpowerrate * 10000).div(getUserSelfHash(user).add(getAddedBasePower(user)));
    }

    function AddContractPower(address user,uint256 amount) public onlyOwner 
    {
         uint256 oneshare=getOneshareNow();
        _pendinglib[user]= getPendingLIZS(user);
        _takedlib[user]= oneshare;
        _baseLibHash[user]=amount;
    }

    function StackThreeCoinCost(uint256 amount) public view returns (uint256[2] memory)
    {
        uint256[2] memory kk;
        kk[0]=getOneUsdtToCoin(_liztrade).mul(amount).div(2e18);
        kk[1]=getOneUsdtToCoin(_littrade).mul(amount).div(2e18);
        return kk;
    }

    function AddUserPower(address user,uint256 amounta,uint256 amountb ) public onlyOwner 
    {
        _baseLibHash[user] = _baseLibHash[user].add(amounta);
        _extendLibhash[user]= _extendLibhash[user].add(amountb);
        LogCheckPoint(amounta + amountb * 15, true);
    }

    function UpdateInviteCount(address user,uint256 pare) public onlyOwner
    {
        _invitecount[user] = pare;
    }

    function StackThreeCoin(uint256 usdtcost) public 
    {
        address user=msg.sender;
        MappingUserFromOld(user);
        uint256[2] memory payinfo=StackThreeCoinCost(usdtcost);
        _lizaddr.safeTransferFrom(user, address(this), payinfo[0]);
        _litaddress.safeTransferFrom(user, address(this), payinfo[1]);
        _usdtaddress.safeTransferFrom(user, address(this), usdtcost);

        address[] memory path1=new address[](2);
        path1[0]= _usdtaddress;
        path1[1]= _libaddr;
       
        uint256 deadline=block.timestamp + 86400;
        uint[] memory amounte =IPancakeRouter(_router).swapExactTokensForTokens(IBEP20(_usdtaddress).balanceOf(address(this)), 0, path1, address(this),deadline);
        IBEP20(_libaddr).burn(amounte[1]);

        uint256 oneshare=getOneshareNow();
        _pendinglib[user]= getPendingLIZS(user);
        _takedlib[user]= oneshare;

        if(getUserSelfHash(user) > 0)
            _pendingliz[user]=getPendingLIZ(user);
        _takedliz[user] = _lizminer.getOneshareNow();

        _baseLibHash[user] = _baseLibHash[user].add(usdtcost);
        _extendLibhash[user]= _extendLibhash[user].add(usdtcost.mul(23).div(15));
 
        uint256 cut=payinfo[1].div(2);
        address parent=user;
        _litaddress.safeTransfer(_liblppool, cut);
        IBOXNEW(_liblppool).AddCreditD(cut);
        uint256 onecut=payinfo[1].mul(3).div(100);
        uint256 giveliz= payinfo[0].mul(5).div(100);
        uint j=0;
        for(uint i=0;i<20;i++)
        {
            parent = _lizminer.getParent(parent);
            if(parent==address(0))
                break;

            if(i==0 && _baseLibHash[user] == usdtcost)
                _invitecount[parent] = getInviteCount(parent) + 1;
 
            if(getInviteCount(parent)>= j+1)
            {
                j++;
                if(j>=10)
                    break;
                cut += onecut;
                _lizaddr.safeTransfer(parent, giveliz);
                _litaddress.safeTransfer(parent, onecut);
            }
        }

        IBEP20(_lizaddr).transfer(address(0xdead), payinfo[0].div(2));
        IBEP20(_litaddress).burn(payinfo[1].sub(cut));
        uint256 addhash=usdtcost.mul(4);
        _pendinglib[_liblppool]= getPendingLIZS(_liblppool);
        _takedlib[_liblppool]= oneshare;
        _baseLibHash[_liblppool] = _baseLibHash[_liblppool].add(addhash.div(2));
        _pendinglib[_litminera]= getPendingLIZS(_litminera);
        _takedlib[_litminera]= oneshare;
        _baseLibHash[_litminera] = _baseLibHash[_litminera].add(addhash.div(2));
        LogCheckPoint(usdtcost.mul(28), true);
    }

    function StackPower(uint256 amounts) public
    {
        address user=msg.sender;
        MappingUserFromOld(user);
        require(getAddedBasePower(user).add(amounts) <= getUserSelfHash(user),"MaxExceed");
        uint256 paylit=getStackCostLit(amounts);
        _litaddress.safeTransferFrom(user, address(this), paylit);
        _usdtaddress.safeTransferFrom(user, address(this), amounts.div(2));

        address[] memory path1=new address[](2);
        path1[0]= _usdtaddress;
        path1[1]= _libaddr;
       
        uint256 deadline=block.timestamp + 86400;
        uint[] memory amounte =IPancakeRouter(_router).swapExactTokensForTokens(IBEP20(_usdtaddress).balanceOf(address(this)), 0, path1, address(this),deadline);
        IBEP20(_libaddr).burn(amounte[1]);

        uint256 oneshare=getOneshareNow();
        _pendinglib[user]= getPendingLIZS(user);
        _takedlib[user]= oneshare;
        if(getUserSelfHash(user) > 0)
            _pendingliz[user]=getPendingLIZ(user);
        _takedliz[user] = _lizminer.getOneshareNow();

        uint256 oldhash= getTotalLIBPower(user);
        _extendLibhash[user]= _extendLibhash[user].add(amounts);
        uint256 newhash= getTotalLIBPower(user);
        uint256 cut=paylit.div(2);
        address parent=user;
        _litaddress.safeTransfer(_liblppool, cut);
        IBOXNEW(_liblppool).AddCreditD(cut);
        uint256 onecut=paylit.mul(3).div(100);
        uint j=0;
        for(uint i=0;i<20;i++)
        {
            parent = _lizminer.getParent(parent);
            if(parent==address(0))
                break;
            if(getInviteCount(parent)>= j+1)
            {
                j++;
                if(j>=10)
                    break;
                cut += onecut;
                _litaddress.safeTransfer(parent, onecut);
            }
        }
        IBEP20(_litaddress).burn(paylit.sub(cut));
        uint256 addhash=newhash.sub(oldhash).mul(4).div(extendpowerrate);
        _pendinglib[_liblppool]= getPendingLIZS(_liblppool);
        _takedlib[_liblppool]= oneshare;
        _baseLibHash[_liblppool] = _baseLibHash[_liblppool].add(addhash.div(2));
        _pendinglib[_litminera]= getPendingLIZS(_litminera);
        _takedlib[_litminera]= oneshare;
        _baseLibHash[_litminera] = _baseLibHash[_litminera].add(addhash.div(2));
        LogCheckPoint(addhash + newhash.sub(oldhash), true);
    }

    function getStackCostLit(uint256 amount) public view returns (uint256)
    {
        uint256 oneulit = getOneUsdtToCoin(_littrade);
        return amount.mul(oneulit).div(1e18).div(2) ;
    }
}