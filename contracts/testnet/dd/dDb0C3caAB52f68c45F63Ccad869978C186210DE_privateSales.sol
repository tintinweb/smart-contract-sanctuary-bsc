// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./AccessControl.sol";
import "./IERC20.sol";

contract privateSales is AccessControl{
    /* ========== STATE VARIABLES ========== */
    //address public  contractAdr;
    uint256 public airDropAmt;
    address public homwereAdr;
    uint256 private allocatedAmtPerAddr;
    
    struct participate{
        uint256 allocated;
        uint256 Bought;
        bool comp_Status;
    }

    mapping(address => uint256) private contractAdrs;
    mapping (address => participate) adrParticipated;

    modifier onlyAdmin (){
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }

    event tknWithDraw(address indexed Spender, uint Amount, address contractAdr);
    event partipateEvt(address indexed Buyer, uint Amount, address contractAdr);

    constructor(address _homwereAdr) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        homwereAdr = _homwereAdr;
    }

    function setAddrAllocation( uint256 _allocation) public onlyAdmin{
        allocatedAmtPerAddr = _allocation;
    }

    function getAddrAllocation() public view returns(uint256){
        return allocatedAmtPerAddr;
    }

    function setPrice(address _conaddress, uint256 _price) public onlyAdmin{
        contractAdrs[_conaddress] = _price;
    }

    function getPrice(address _conaddress) public view returns(uint256){
        return contractAdrs[_conaddress];
    }

    function getAddrParm(address _addr) public view returns(uint256 _remainAllo,uint256 _bought){
        return (adrParticipated[_addr].allocated,
            adrParticipated[_addr].Bought);
    }

    function withdrawERC(uint amt, address _contractAdr) public onlyAdmin {
        IERC20 Token = IERC20(_contractAdr);
        Token.transfer(msg.sender,amt);
        emit tknWithDraw(msg.sender,amt, _contractAdr);
    }

    function _getQuantity(address _conaddress, uint256 _amt) public view returns (uint256 _Quan){
        _Quan = contractAdrs[_conaddress] / _amt;
    }

    function buyToken(address _conaddress, uint256 _amt) public returns(bool result){
        IERC20 Token = IERC20(_conaddress);
        IERC20 homTkn = IERC20(homwereAdr);
        require(Token.balanceOf(_msgSender()) >= _amt, "INSUFFICIENT ERC20 TOKEN AMOUNT FOR VALUE PROVIDED");
        require(_getQuantity(_conaddress,_amt) <= allocatedAmtPerAddr, "NONE LEFT FOR ADDRESS");
        require(_getQuantity(_conaddress,_amt) + adrParticipated[_msgSender()].Bought <= allocatedAmtPerAddr, "NONE LEFT FOR ADDRESS");
        require(contractAdrs[_conaddress] > 0,"ACCOUNT HAVE ALREADY PARTICIPATED ON THE PRIVATE SELL");
        if(checkAllowance(_conaddress) >= _amt){

            if((adrParticipated[_msgSender()].allocated == 0) 
                && (adrParticipated[_msgSender()].Bought == 0)
                && (adrParticipated[_msgSender()].comp_Status == false))
            {
                participate memory newparticipate;
                newparticipate.allocated = (allocatedAmtPerAddr - _amt);
                newparticipate.Bought = _amt;
                newparticipate.comp_Status = false;
                adrParticipated[_msgSender()] = newparticipate;
            
            }

            Token.transferFrom(_msgSender(),address(this), _amt);
            uint256 Quan = _getQuantity(_conaddress,_amt); //contractAdrs[_conaddress] / _amt;
            homTkn.transfer(_msgSender(), Quan);

            adrParticipated[_msgSender()].allocated -= Quan;
            adrParticipated[_msgSender()].Bought += Quan;

            assert(keccak256(abi.encodePacked(
                adrParticipated[_msgSender()].allocated + 
                adrParticipated[_msgSender()].Bought
                ))
                ==
                keccak256(abi.encodePacked(
                allocatedAmtPerAddr))
            );

            emit partipateEvt(_msgSender(), _amt, _conaddress);

            result = true;
        }else{
            result = false;
        }
        
    }

    function checkAllowance(address _conaddress)public view returns(uint256 allowanceAmt){
        IERC20 Token = IERC20(_conaddress);
        return Token.allowance(_msgSender(), address(this));
    }

}