// SPDX-License-Identifier: MIT


pragma solidity 0.6.12;

import "./BEP20.sol";
import "./Ownable.sol";
// import './SafeBEP20.sol';
// import './IBEP20.sol';

contract UFX_D2 is Ownable {

    //-------------------------- test net --------------------------
    address public busdTokenAddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    BEP20 public BUSD_Token = BEP20(busdTokenAddress);

    //-------------------------- test net --------------------------
    address public UFXTokenAddress = 0xD4fEFc0CE198033a413C8f879cFE65630633aee7;
    BEP20 public UFX_Token = BEP20(UFXTokenAddress);

    address public ufxDevholer;

    event Bought(uint256 amount);
    event Sold(uint256 amount);

    constructor(address _ufxDevholer) public {
        ufxDevholer = _ufxDevholer;
    }

    function sell(uint256 ufxAmount, uint256 busdAmount) public {
        require(ufxAmount > 0, "ufxAmount can not be 0");
        require(busdAmount > 0, "busdAmount can not be 0");

        require(UFX_Token.balanceOf(ufxDevholer) > ufxAmount, "Dev needs more UFX");
        require(BUSD_Token.balanceOf(msg.sender) > busdAmount, "You dont have enough BUSD");


        //spender : hold busd / to : owner
        //Aprrove
        // BUSD_Token._approve(address(msg.sender), ufxDevholer, ufxAmount);
        // UFX_Token._approve(ufxDevholer, address(msg.sender), busdAmount);


        //send BUSD -> Owner(dev)
        BUSD_Token.transferFrom(msg.sender, ufxDevholer, ufxAmount);

        //send UFX -> Investor
        UFX_Token.transferFrom(ufxDevholer, address(this), ufxAmount);
        UFX_Token.transfer(msg.sender, ufxAmount);



        emit Sold(ufxAmount);
    }

    function changeUfxDevHoler(address _newUFXDevHoler) public onlyOwner {
      ufxDevholer = _newUFXDevHoler;
    }

    function balance() public view returns(uint256) {
      return UFX_Token.balanceOf(ufxDevholer);
    }
}