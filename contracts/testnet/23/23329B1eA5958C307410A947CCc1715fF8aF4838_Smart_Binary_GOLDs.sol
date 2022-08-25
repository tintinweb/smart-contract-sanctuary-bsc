/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.4.22 <0.9.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) +
            (value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) -
            (value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

contract GetData1{
 struct Node {
        uint256 leftDirect;
        uint256 rightDirect;
        uint256 todayCountPoint;
        uint256 depth;
        uint256 childs;
        uint256 leftOrrightUpline;
        address UplineAddress;
        address leftDirectAddress;
        address rightDirectAddress;
    }
    mapping(address => Node) private _users;
    mapping(uint256 => address) private _allUsersAddress;


    constructor(){


        _allUsersAddress[0] =  0x62540FcEed5b19c1b0732A593Fd42b95cB7f6E0A ;  
        _users[_allUsersAddress[0]] = Node(  237,  0,  0,    0,    1,   0,
           address(0),
           0xf77aF59DFF41226E2c71eE3ea947227D296985d6 ,
           address(0));
        _allUsersAddress[1] = 0xf77aF59DFF41226E2c71eE3ea947227D296985d6  ;    
        _users[_allUsersAddress[1]] = Node( 236,  0,    0,    1,    1,   0,
           0x00e21f2B131CD5ba0c2e5594B1a7302A6Aa64152 ,
           0x3b43741283c4B0f4ad04e4ee678ff8740d85dbCf ,
           address(0));
        _allUsersAddress[2] =  0x3b43741283c4B0f4ad04e4ee678ff8740d85dbCf ;    
        _users[_allUsersAddress[2]] = Node(  235,  0,   0,    2,    1,   0,
           0xf77aF59DFF41226E2c71eE3ea947227D296985d6 ,
           0xCb0ec08392628de2455C31b3e60874f90de5EbbC ,
           address(0));
        _allUsersAddress[3] =  0xCb0ec08392628de2455C31b3e60874f90de5EbbC ;    
        _users[_allUsersAddress[3]] = Node( 234,  0,   0,  3,    1,   0,
           0x3b43741283c4B0f4ad04e4ee678ff8740d85dbCf ,
           0x5be0033f13107eE74646f8C5f0391E702b22f83d ,
           address(0)); 
        _allUsersAddress[4] = 0x5be0033f13107eE74646f8C5f0391E702b22f83d  ;   
        _users[_allUsersAddress[4]] = Node(   233,  0,   0,    4,    1,   0,
           0xCb0ec08392628de2455C31b3e60874f90de5EbbC  ,
           0xC09Fe0aCe18D82bb37472eE0DffD102FC04824F2 ,
           address(0));
        _allUsersAddress[5] = 0xC09Fe0aCe18D82bb37472eE0DffD102FC04824F2  ;    
        _users[_allUsersAddress[5]] = Node(  232,  0,    0,    5,    1,   0,
           0x5be0033f13107eE74646f8C5f0391E702b22f83d  ,
           0xACE7d5668af0dDe64cd6d99aBa68CC03e32A45Af ,
           address(0));
        _allUsersAddress[6] =  0xACE7d5668af0dDe64cd6d99aBa68CC03e32A45Af ;    
        _users[_allUsersAddress[6]] = Node(  231,  0,   0,    6,    1,   0,
           0xC09Fe0aCe18D82bb37472eE0DffD102FC04824F2 ,
           0x431430B832aa27d7807144ca4897A4d17215F259 ,
           address(0));
        _allUsersAddress[7] = 0x431430B832aa27d7807144ca4897A4d17215F259  ;    
        _users[_allUsersAddress[7]] = Node(  0,  160,  0,    7,    2,   0,
           0xACE7d5668af0dDe64cd6d99aBa68CC03e32A45Af  ,
           0x55559502D56270570540C3e9237c6a0b1f9D59cF ,
           0x38AdE30FCf537ff25A5eEE44bCA8E0c2747fB766);
        _allUsersAddress[8] =  0x55559502D56270570540C3e9237c6a0b1f9D59cF ;    
        _users[_allUsersAddress[8]] = Node(  34,  0, 0,    8,    1,   0,
            0x431430B832aa27d7807144ca4897A4d17215F259 ,
            0xE4D245DF7912429F2dEb544B8a671cd452A3136c ,
           address(0));
        _allUsersAddress[9] =  0xE4D245DF7912429F2dEb544B8a671cd452A3136c ;    
        _users[_allUsersAddress[9]] = Node(  21,  0,   0,    9,    2,   0,
            0x55559502D56270570540C3e9237c6a0b1f9D59cF ,
            0x5E7bC81e8FEdbad38C79217F62DFd16BB9AEC93E ,
            0x6F1445F6F03c78d611a5c972159e3Af6A57d030E);
         _allUsersAddress[10] =  0x5E7bC81e8FEdbad38C79217F62DFd16BB9AEC93E ;    
        _users[_allUsersAddress[10]] = Node( 24,  0,   0,    10,    2,   0,
           0xE4D245DF7912429F2dEb544B8a671cd452A3136c ,
           0x91390B082094f38DC3e6204a723982d16F9FDD7b ,
           0xf0975aD25083E25164038355f6DC761Ae5C6fE5e);
         _allUsersAddress[11] = 0x6F1445F6F03c78d611a5c972159e3Af6A57d030E  ;    
        _users[_allUsersAddress[11]] = Node(  3,  0,   0,    10,    2,   1,
          0xE4D245DF7912429F2dEb544B8a671cd452A3136c ,
          0x47877d088a0CeED6d97624EaaDD4B67C74A6DEEa ,
          0x00BB241f47408d3b1d3e7454870894Fa1310A9d6);
         _allUsersAddress[12] =  0x47877d088a0CeED6d97624EaaDD4B67C74A6DEEa ;    
        _users[_allUsersAddress[12]] = Node( 1,  0,   0,    1,    2,   0,
           0x6F1445F6F03c78d611a5c972159e3Af6A57d030E  ,
           0xD6968E60e8425DB3167F443Fb0dba9f02A4F83ba ,
           0x0E2cDF53402B6f1E01746f4860f9D41502362c2C);
         _allUsersAddress[13] =  0xD6968E60e8425DB3167F443Fb0dba9f02A4F83ba ;    
        _users[_allUsersAddress[13]] = Node( 1,  0,   0,    12,    1,   0,
           0x47877d088a0CeED6d97624EaaDD4B67C74A6DEEa  ,
           0x45Bc9D6c92a50FBf0034C70B5D046315197c1f75 ,
           address(0));
         _allUsersAddress[14] =  0x0E2cDF53402B6f1E01746f4860f9D41502362c2C ;    
        _users[_allUsersAddress[14]] = Node(   0,  0,   0,   12,    0,   1,
            0x47877d088a0CeED6d97624EaaDD4B67C74A6DEEa  ,
           address(0),     address(0));
         _allUsersAddress[15] =  0x45Bc9D6c92a50FBf0034C70B5D046315197c1f75 ;   
        _users[_allUsersAddress[15]] = Node(   0,   0,   0,    13,    0,   0,
            0xD6968E60e8425DB3167F443Fb0dba9f02A4F83ba ,
           address(0),           address(0));
         _allUsersAddress[16] =  0x91390B082094f38DC3e6204a723982d16F9FDD7b ;    
        _users[_allUsersAddress[16]] = Node(   22,  0,    0,    11,    2,   0,
           0x5E7bC81e8FEdbad38C79217F62DFd16BB9AEC93E  ,
           0xDB03C23E4DD57a0D6d2F4956930DF82A1FC3C3c7 ,
           0x8c708Aa625EA68c0E9D9D4C1aF023b496277d20C);
         _allUsersAddress[17] =  0xDB03C23E4DD57a0D6d2F4956930DF82A1FC3C3c7 ;    
        _users[_allUsersAddress[17]] = Node(     22,  0,      0,    12,    1,   0,
           0x91390B082094f38DC3e6204a723982d16F9FDD7b  ,
           0x67Fd05047369fD28764bE5c94cCC3d44738ae909 ,
           address(0));
         _allUsersAddress[18] =  0x8c708Aa625EA68c0E9D9D4C1aF023b496277d20C ;    
        _users[_allUsersAddress[18]] = Node(    0,  0,      0,    12,    0,   1,
           0x91390B082094f38DC3e6204a723982d16F9FDD7b  ,
           address(0),    address(0));
         _allUsersAddress[19] =  0xf0975aD25083E25164038355f6DC761Ae5C6fE5e ;    
        _users[_allUsersAddress[19]] = Node(   0,  0,    0,    11,    0,   1,
           0x5E7bC81e8FEdbad38C79217F62DFd16BB9AEC93E  ,
           address(0),           address(0));
         _allUsersAddress[20] =  0x00BB241f47408d3b1d3e7454870894Fa1310A9d6 ;    
        _users[_allUsersAddress[20]] = Node(  0,  0,    0,    11,    0,   1,
           0x6F1445F6F03c78d611a5c972159e3Af6A57d030E  ,
           address(0),           address(0));           
         _allUsersAddress[21] = 0x38AdE30FCf537ff25A5eEE44bCA8E0c2747fB766   ;  
       _users[_allUsersAddress[21]] = Node(  194,  0,   0,    8,    1,   1,
           0x431430B832aa27d7807144ca4897A4d17215F259 ,
           0x9E92934ecadBA4457C97A7F4a3cA31F8C504699C ,
           address(0));
         _allUsersAddress[22] =  0x9E92934ecadBA4457C97A7F4a3cA31F8C504699C  ;     
        _users[_allUsersAddress[22]] = Node(
            0,  153,      0,    9,    2,   0,
           0x38AdE30FCf537ff25A5eEE44bCA8E0c2747fB766 ,
           0xc5d09D7733714ac8927FA0590C32e57E81Cc14d9 ,
           0x94075A5ffc9DeE5880c6A85fa9F71eDbE0C09514);
         _allUsersAddress[23] =  0xc5d09D7733714ac8927FA0590C32e57E81Cc14d9  ;    
        _users[_allUsersAddress[23]] = Node(  0,  55,      0,    10,    1,   0,
            0x9E92934ecadBA4457C97A7F4a3cA31F8C504699C  ,
            0xACf506Bd7512e3BcDBDE5efa346D8e7F2fe19948,
           address(0));
         _allUsersAddress[24] =  0x94075A5ffc9DeE5880c6A85fa9F71eDbE0C09514  ;    
        _users[_allUsersAddress[24]] = Node(  16,  0,      0,    10,    2,   1,
           0x9E92934ecadBA4457C97A7F4a3cA31F8C504699C ,
           0x97e7dDC442368C8C318caDA749A6aA20D6f43597 ,
           0x9c7Ea742584cAd4c2C14eebee27851221b39FEb4);
         _allUsersAddress[25] =  0xACf506Bd7512e3BcDBDE5efa346D8e7F2fe19948  ;     
        _users[_allUsersAddress[25]] = Node(  126,  0,    0,    11,    2,   0,
            0xc5d09D7733714ac8927FA0590C32e57E81Cc14d9  ,
            0x90A3198997CdB0240897826293C09750aF314995 ,
            0xA2630d657F1df3f16C1743dfc0c76e3FE299D885);
         _allUsersAddress[26] =  0x97e7dDC442368C8C318caDA749A6aA20D6f43597  ;     
        _users[_allUsersAddress[26]] = Node(  25,  0,    0,   11,    1,   0,
           0x94075A5ffc9DeE5880c6A85fa9F71eDbE0C09514 ,
           0x58F23d9363b285A716ED50F3fD08876546e720dc ,
           address(0));
         _allUsersAddress[27] = 0x9c7Ea742584cAd4c2C14eebee27851221b39FEb4  ;     
        _users[_allUsersAddress[27]] = Node(   9,  0,     0,    11,    1,   1,
           0x94075A5ffc9DeE5880c6A85fa9F71eDbE0C09514  ,
           0xA29c22A797c5cC516a6747bCaC24DFFE88d14341 ,
           address(0));
         _allUsersAddress[28] = 0x58F23d9363b285A716ED50F3fD08876546e720dc ; 
        _users[_allUsersAddress[28]] = Node(     2,  0,  0,  12,  2,  0,
           0x97e7dDC442368C8C318caDA749A6aA20D6f43597 ,
           0x186Fd04367eE5f77F6c060c6c1A8FEccaF484cBd ,
           0xcb5a2ED3c3E66415779eae77a60e511dbE68D20e);
         _allUsersAddress[29] = 0xA29c22A797c5cC516a6747bCaC24DFFE88d14341 ; 
        _users[_allUsersAddress[29]] = Node(  0,  2,    0,  12,    2,  0,
           0x9c7Ea742584cAd4c2C14eebee27851221b39FEb4 ,
           0x3b1A1346d6e9ed7fEa8b60e3bB95e3ef6050687e ,
           0xB97E4Ec964AE99024FB4F48c0b32e1772CE7e13b);
         _allUsersAddress[30] = 0xB97bDF4D97006ff7328cc626f9A58945F7dF94D3 ;  
        _users[_allUsersAddress[30]] = Node(   0,  0,  0,  28,  0,  1,
           0x0b6d1F968782A642eFf077e9b717Bea91a319d20 ,
           address(0) ,        address(0));
         _allUsersAddress[31] = 0x186Fd04367eE5f77F6c060c6c1A8FEccaF484cBd ; 
        _users[_allUsersAddress[31]] = Node(   6,  0,  0,  13,  2,  0,
           0x58F23d9363b285A716ED50F3fD08876546e720dc ,
           0xb01A709ec722f79F57314596409c6Ff4a228f893 ,
           0xbB247B8a43CB543104F630d57feA6d3622834D2E);
         _allUsersAddress[32] = 0xcb5a2ED3c3E66415779eae77a60e511dbE68D20e ;  
        _users[_allUsersAddress[32]] = Node(  0,  4,  0,  13,  2,  1,
           0x58F23d9363b285A716ED50F3fD08876546e720dc ,
           0x7092Bb880e517bbD35B0f73bB6dfF3de03d89A6C ,
           0x0851aB2Ed004ED9954Da6B984B8E23aa580715AB);
         _allUsersAddress[33] = 0xb01A709ec722f79F57314596409c6Ff4a228f893 ;  
        _users[_allUsersAddress[33]] = Node(    6,  0,  0,  14,  2,  0,
           0x186Fd04367eE5f77F6c060c6c1A8FEccaF484cBd ,
           0x58fA11a71c5094d7001A11Eae8d785EA2DF2a1D9 ,
           0x6534F427757252a4cf59D51f04579acd78c6B850);
         _allUsersAddress[34] = 0xbB247B8a43CB543104F630d57feA6d3622834D2E ;  
        _users[_allUsersAddress[34]] = Node( 0,  0,  0,  14,  2,  1,
          0x186Fd04367eE5f77F6c060c6c1A8FEccaF484cBd ,
          0x8915715f6BD1064E1fb31e61c393a3f3cdc476cD ,
          0xB7ADe88e462a9FDa57CE0C3Ed93bE0D3da46587f);
         _allUsersAddress[35] = 0x7092Bb880e517bbD35B0f73bB6dfF3de03d89A6C ; 
        _users[_allUsersAddress[35]] = Node(   0,  0,  0,  14,  2,  0,
           0xcb5a2ED3c3E66415779eae77a60e511dbE68D20e ,
           0x027aee0Aa5741D32be1e19b2Ff53d9570906C04b ,
           0x000fa941f36196926e5aB2928e8864836A7F02A4);
         _allUsersAddress[36] = 0x0851aB2Ed004ED9954Da6B984B8E23aa580715AB ; 
        _users[_allUsersAddress[36]] = Node(    0,  4,  0,  14,  2,  1,
           0xcb5a2ED3c3E66415779eae77a60e511dbE68D20e ,
           0x37ca1255a0e312A6361877D9Dc305B5E747ddB73 ,
           0x9cb3074E6F7f46b87494FEAD45aa186e0beEA8A5);
         _allUsersAddress[37] = 0x58fA11a71c5094d7001A11Eae8d785EA2DF2a1D9 ; 
        _users[_allUsersAddress[37]] = Node(   6,  0,  0,  15,  2,  0,
           0xb01A709ec722f79F57314596409c6Ff4a228f893 ,
           0xC8c5bF9D3D7b9cEC50a896afDa4A16a87b57d740 ,
           0x6534F427757252a4cf59D51f04579acd78c6B850);
         _allUsersAddress[38] = 0x6534F427757252a4cf59D51f04579acd78c6B850 ;  
        _users[_allUsersAddress[38]] = Node(     0,  0,  0,  15,  0,  1,
          0xb01A709ec722f79F57314596409c6Ff4a228f893 ,
            address(0),            address(0));
         _allUsersAddress[39] = 0x8915715f6BD1064E1fb31e61c393a3f3cdc476cD ;  
        _users[_allUsersAddress[39]] = Node(     0,  0,  0,  15,  0,  0,
          0xbB247B8a43CB543104F630d57feA6d3622834D2E ,
            address(0),        address(0));
         _allUsersAddress[40] = 0xB7ADe88e462a9FDa57CE0C3Ed93bE0D3da46587f ;  
        _users[_allUsersAddress[40]] = Node(   0,  0,  0,  15,  0,  1,
          0xbB247B8a43CB543104F630d57feA6d3622834D2E ,
            address(0),        address(0));
         _allUsersAddress[41] = 0x027aee0Aa5741D32be1e19b2Ff53d9570906C04b ;  
        _users[_allUsersAddress[41]] = Node(    0,  0,  0,  15,  0,  0,
         0x7092Bb880e517bbD35B0f73bB6dfF3de03d89A6C ,
            address(0),    address(0));
         _allUsersAddress[42] = 0x000fa941f36196926e5aB2928e8864836A7F02A4 ;  
        _users[_allUsersAddress[42]] = Node(   0,  0,  0,  15,  0,  1,
         0x7092Bb880e517bbD35B0f73bB6dfF3de03d89A6C ,
            address(0),            address(0));
         _allUsersAddress[43] = 0x37ca1255a0e312A6361877D9Dc305B5E747ddB73 ;  
        _users[_allUsersAddress[43]] = Node(   0,  0,  0,  15,  0,  0,
            0x0851aB2Ed004ED9954Da6B984B8E23aa580715AB ,
            address(0),            address(0));
         _allUsersAddress[44] = 0x9cb3074E6F7f46b87494FEAD45aa186e0beEA8A5 ;  
        _users[_allUsersAddress[44]] = Node(   4,  0,  0,  15,  1,  1,
            0x0851aB2Ed004ED9954Da6B984B8E23aa580715AB ,
            0xa6935Ee84228C6144a28a057921E4539555AE4c2,
            address(0));
         _allUsersAddress[45] = 0xa6935Ee84228C6144a28a057921E4539555AE4c2 ;  
        _users[_allUsersAddress[45]] = Node(       1,  0,  0,  16,  2,  0,
           0x9cb3074E6F7f46b87494FEAD45aa186e0beEA8A5 ,
           0x88c9BaC13f404344EE9b67fAf3e440E0c0949E30 ,
           0xe1553101A35800247De27862dA6E71110cfbf0Db );
         _allUsersAddress[46] = 0x88c9BaC13f404344EE9b67fAf3e440E0c0949E30 ;  
        _users[_allUsersAddress[46]] = Node(    1,  0,  0,  17,  1,  0,
           0xa6935Ee84228C6144a28a057921E4539555AE4c2 ,
           0x93A7002Bf2BEcDc767E2DeCe51ac85A1ad0aA9C5 ,
            address(0));
         _allUsersAddress[47] = 0xe1553101A35800247De27862dA6E71110cfbf0Db ;  
        _users[_allUsersAddress[47]] = Node(  0,  0,  0,  17,  0,  1,
           0xa6935Ee84228C6144a28a057921E4539555AE4c2 ,
            address(0),      address(0));
         _allUsersAddress[48] = 0x93A7002Bf2BEcDc767E2DeCe51ac85A1ad0aA9C5; 
        _users[_allUsersAddress[48]] = Node(  0,  0,  0,  18,  0,  0,
            0x88c9BaC13f404344EE9b67fAf3e440E0c0949E30 ,
            address(0),        address(0));
         _allUsersAddress[49] = 0xC8c5bF9D3D7b9cEC50a896afDa4A16a87b57d740 ; 
        _users[_allUsersAddress[49]] = Node(    1,  0,  0,  16,  2,  0,
           0x58fA11a71c5094d7001A11Eae8d785EA2DF2a1D9 ,
           0xa3b4D5284eaC7E25c3e8ff3aEC85063151838122 ,
           0xeEB180643B2012E094469E965FBcc82325cda6F2);
         _allUsersAddress[50] = 0xa3b4D5284eaC7E25c3e8ff3aEC85063151838122 ;  
        _users[_allUsersAddress[50]] = Node(     2,  0,  0,  17,  1,  0,
           0xC8c5bF9D3D7b9cEC50a896afDa4A16a87b57d740 ,
           0x5c0487304A9238ab5c7ACAAf1Ad22c80Eb4b5450 ,
            address(0));
         _allUsersAddress[51] = 0xeEB180643B2012E094469E965FBcc82325cda6F2 ;  
        _users[_allUsersAddress[51]] = Node(   1,  0,  0,  17,  1,  1,
          0xC8c5bF9D3D7b9cEC50a896afDa4A16a87b57d740 ,
          0x7d99DB26dEac909a306B5Ab3608892E0b09FF3FF ,
            address(0));
         _allUsersAddress[52] = 0x5c0487304A9238ab5c7ACAAf1Ad22c80Eb4b5450 ;  
        _users[_allUsersAddress[52]] = Node(    1,  0,  0,  18,  1,  0,
          0xa3b4D5284eaC7E25c3e8ff3aEC85063151838122 ,
          0xC18917d611c8f623fbe69d89b969ca01cb8a7972 ,
            address(0));
         _allUsersAddress[53] = 0xC18917d611c8f623fbe69d89b969ca01cb8a7972;  
        _users[_allUsersAddress[53]] = Node(   0,  0,  0,  19,  0,  0,
          0x5c0487304A9238ab5c7ACAAf1Ad22c80Eb4b5450 ,
            address(0),      address(0));
         _allUsersAddress[54] = 0x7d99DB26dEac909a306B5Ab3608892E0b09FF3FF; 
        _users[_allUsersAddress[54]] = Node(   0,  0,  0,  18,  0,  0,
           0xeEB180643B2012E094469E965FBcc82325cda6F2 ,
            address(0),    address(0));
        _allUsersAddress[55] = 0x226F3DF5DaD7c3D02530664956F5293306e7038D  ;  
        _users[_allUsersAddress[55]] = Node(  0,   0,   0,   28,    0,   1,
            0x1fA3fc334707e0AFf0d0a1Bc81F0A92328219445  ,
            address(0),       address(0));
         _allUsersAddress[56] = 0x3b1A1346d6e9ed7fEa8b60e3bB95e3ef6050687e ; 
        _users[_allUsersAddress[56]] = Node(   2,  0,     0,  13,     1,  0,
           0xA29c22A797c5cC516a6747bCaC24DFFE88d14341 ,
           0x33B99757367584e5443F13De8D06baf727855aa2 ,
            address(0));
         _allUsersAddress[57] = 0xB97E4Ec964AE99024FB4F48c0b32e1772CE7e13b ; 
        _users[_allUsersAddress[57]] = Node(   4,  0,    0,  13,     1,  1,
           0xA29c22A797c5cC516a6747bCaC24DFFE88d14341 ,
          0x39C1Ec28de6C2dB19df38a9f5aE79FF769892F51 ,
            address(0));
         _allUsersAddress[58] = 0x33B99757367584e5443F13De8D06baf727855aa2 ; 
        _users[_allUsersAddress[58]] = Node( 1,  0,       0,  14,    1,  0,
           0x3b1A1346d6e9ed7fEa8b60e3bB95e3ef6050687e ,
           0xE0e6733d95AD67013473F8A1FF74Ce3DFB9a0CF2 ,
            address(0));
         _allUsersAddress[59] = 0xE0e6733d95AD67013473F8A1FF74Ce3DFB9a0CF2 ; 
        _users[_allUsersAddress[59]] = Node(    0,  0,       0,  15,     0,  0,
           0x33B99757367584e5443F13De8D06baf727855aa2 ,
            address(0),      address(0));
         _allUsersAddress[60] = 0x39C1Ec28de6C2dB19df38a9f5aE79FF769892F51 ; 
        _users[_allUsersAddress[60]] = Node( 1,  0,    0,  14,    2,  0,
           0xB97E4Ec964AE99024FB4F48c0b32e1772CE7e13b ,
           0x4154Ba2796a8Dbf11fB142Dd16588C5C858681C9 ,
           0x8edC77E34eC34Dd484534C65FE13818111476086);
         _allUsersAddress[61] = 0x4154Ba2796a8Dbf11fB142Dd16588C5C858681C9 ; 
        _users[_allUsersAddress[61]] = Node(   1,  0,    0,  15,    1,  0,
           0x39C1Ec28de6C2dB19df38a9f5aE79FF769892F51 ,
           0x3269478050c53b4996D53988268bbCceF83328bc ,
            address(0));
         _allUsersAddress[62] = 0x8edC77E34eC34Dd484534C65FE13818111476086 ; 
        _users[_allUsersAddress[62]] = Node(  0,  0,    0,  15,   0,  1,
           0x39C1Ec28de6C2dB19df38a9f5aE79FF769892F51 ,
            address(0),       address(0));
         _allUsersAddress[63] = 0x3269478050c53b4996D53988268bbCceF83328bc ; 
        _users[_allUsersAddress[63]] = Node( 0,  0,  0,  16,   0,  0,
           0x4154Ba2796a8Dbf11fB142Dd16588C5C858681C9 ,
            address(0),  address(0));
         _allUsersAddress[64] = 0x67Fd05047369fD28764bE5c94cCC3d44738ae909 ;  
        _users[_allUsersAddress[64]] = Node(    19,  0,  0,  13,  2,  0,
           0xDB03C23E4DD57a0D6d2F4956930DF82A1FC3C3c7 ,
           0x57AC0954dd61F46eBc0fD9d073bAC160847b28C3 ,
           0xdc97C4d521ffb4033E091A64fbA6752A96E26f52);    
         _allUsersAddress[65] = 0x57AC0954dd61F46eBc0fD9d073bAC160847b28C3 ;  
        _users[_allUsersAddress[65]] = Node(    19,  0,  0,  14,  1,  0,
           0x67Fd05047369fD28764bE5c94cCC3d44738ae909 ,
           0x1e7eC88Fe98190FD3533d06700eaF8a76A92b106 ,
            address(0));
         _allUsersAddress[66] = 0xdc97C4d521ffb4033E091A64fbA6752A96E26f52 ;  
        _users[_allUsersAddress[66]] = Node(    0,  0,  0,  14,  0,  1,
           0x67Fd05047369fD28764bE5c94cCC3d44738ae909 ,
           address(0),        address(0));
         _allUsersAddress[67] = 0x1e7eC88Fe98190FD3533d06700eaF8a76A92b106 ;  
        _users[_allUsersAddress[67]] = Node(
            18,  0, 0,  15,  1,  0,
           0x57AC0954dd61F46eBc0fD9d073bAC160847b28C3 ,
           0x8662195eF9a2A5Bdbd1c46a7c9e2b52599021c05 ,
            address(0));
         _allUsersAddress[68] = 0x8662195eF9a2A5Bdbd1c46a7c9e2b52599021c05 ;  
        _users[_allUsersAddress[68]] = Node(    17,  0,  0,  16,  1,  0,
           0x1e7eC88Fe98190FD3533d06700eaF8a76A92b106 ,
           0x5cCc93Ed78EaCE53ff8C0f70A6501287D989A695 ,
            address(0));
         _allUsersAddress[69] = 0x5cCc93Ed78EaCE53ff8C0f70A6501287D989A695 ;  
        _users[_allUsersAddress[69]] = Node(   16,  0,  0,  17,  1,  0,
           0x8662195eF9a2A5Bdbd1c46a7c9e2b52599021c05 ,
           0x8c909F37acf50C8636CE9DE855c5EaC81e44eF62 ,
            address(0));
         _allUsersAddress[70] = 0x8c909F37acf50C8636CE9DE855c5EaC81e44eF62 ;  
        _users[_allUsersAddress[70]] = Node(   15,  0,  0,  18,  1,  0,
           0x5cCc93Ed78EaCE53ff8C0f70A6501287D989A695 ,
           0x31CCD4546d27C0cb40d1d5851bc3e03D29335364 ,
            address(0));
         _allUsersAddress[71] = 0x31CCD4546d27C0cb40d1d5851bc3e03D29335364 ;  
        _users[_allUsersAddress[71]] = Node(  8,  0,  0,  19,  2,  0,
           0x8c909F37acf50C8636CE9DE855c5EaC81e44eF62 ,
           0x4aAa21BaE3123D72De93b9E3B658b8E65ef234aE ,
           0x0C0A4aC595a219bB03489Ff45e365E832eF7a989);
         _allUsersAddress[72] = 0x4aAa21BaE3123D72De93b9E3B658b8E65ef234aE ;  
        _users[_allUsersAddress[72]] = Node(   10,  0,  0,  20,  1,  0,
           0x31CCD4546d27C0cb40d1d5851bc3e03D29335364 ,
           0xDdE5A8A5f5a3dd1DD366D254286966aaF30b15cE ,
            address(0));
        _allUsersAddress[73] = 0x0C0A4aC595a219bB03489Ff45e365E832eF7a989 ;  
        _users[_allUsersAddress[73]] = Node(  2,  0,  0,  20,  1,  1,
           0x31CCD4546d27C0cb40d1d5851bc3e03D29335364 ,
           0x356E98d5E05601515834C4C78eAFBB4c023DfA48 ,
            address(0));
         _allUsersAddress[74] = 0x356E98d5E05601515834C4C78eAFBB4c023DfA48 ;  
        _users[_allUsersAddress[74]] = Node(   1,  0,  0,  21,  1,  0,
           0x0C0A4aC595a219bB03489Ff45e365E832eF7a989 ,
           0x8b6D0dC0cdCB53ED581D694Ff102D4863454A1e8 ,
            address(0));
         _allUsersAddress[75] = 0x8b6D0dC0cdCB53ED581D694Ff102D4863454A1e8 ;  
        _users[_allUsersAddress[75]] = Node(  0,  0,  0,  22,  0,  0,
           0x356E98d5E05601515834C4C78eAFBB4c023DfA48 ,
            address(0),     address(0));
         _allUsersAddress[76] = 0xDdE5A8A5f5a3dd1DD366D254286966aaF30b15cE ;  
        _users[_allUsersAddress[76]] = Node( 7,  0,  0,  21,  2,  0,
           0x4aAa21BaE3123D72De93b9E3B658b8E65ef234aE ,
           0xBdb9C60DaF43EE1ce5306F3176F05346B4496B22 ,
           0x3C2D0A52473306D75a565bd20F7d773e5A632C1C);
         _allUsersAddress[77] = 0x3C2D0A52473306D75a565bd20F7d773e5A632C1C ;  
        _users[_allUsersAddress[77]] = Node(  0,  0,  0,  22,  0,  1,
           0xDdE5A8A5f5a3dd1DD366D254286966aaF30b15cE ,
            address(0),    address(0));
         _allUsersAddress[78] = 0xBdb9C60DaF43EE1ce5306F3176F05346B4496B22 ;  
        _users[_allUsersAddress[78]] = Node(  7,  0,  0,  22,  1,  0,
           0xDdE5A8A5f5a3dd1DD366D254286966aaF30b15cE ,
           0x8b0058eC4Dc9a346Dcc1cdfFEbBcDAf44A8A5b27 ,
            address(0));
         _allUsersAddress[79] = 0x8b0058eC4Dc9a346Dcc1cdfFEbBcDAf44A8A5b27 ;  
        _users[_allUsersAddress[79]] = Node( 6,  0,  0,  23,  1,  0,
           0xBdb9C60DaF43EE1ce5306F3176F05346B4496B22 ,
           0x40B97E34bF576D78A52025D3947B8721BB887F73 ,
            address(0));
         _allUsersAddress[80] = 0x40B97E34bF576D78A52025D3947B8721BB887F73 ;  
        _users[_allUsersAddress[80]] = Node(  5,  0,  0,  24,  1,  0,
           0x8b0058eC4Dc9a346Dcc1cdfFEbBcDAf44A8A5b27 ,
           0xFd241595b8b96CC20Cb2e31a4A7901f8E4Ef478d ,
            address(0));
         _allUsersAddress[81] = 0xFd241595b8b96CC20Cb2e31a4A7901f8E4Ef478d ;  
        _users[_allUsersAddress[81]] = Node(  4,  0,  0,  25,  1,  0,
           0x40B97E34bF576D78A52025D3947B8721BB887F73 ,
           0xcbC394a18467E497d5491BC8EB5f7ABbACA7ee7F ,
            address(0));
         _allUsersAddress[82] = 0xcbC394a18467E497d5491BC8EB5f7ABbACA7ee7F ;  
        _users[_allUsersAddress[82]] = Node(  3,  0,  0,  26,  1,  0,
           0xFd241595b8b96CC20Cb2e31a4A7901f8E4Ef478d ,
           0x0b6d1F968782A642eFf077e9b717Bea91a319d20 ,
            address(0));
         _allUsersAddress[83] = 0x0b6d1F968782A642eFf077e9b717Bea91a319d20 ;  
        _users[_allUsersAddress[83]] = Node(  0,  0,  0,  27,  2,  0,
           0xcbC394a18467E497d5491BC8EB5f7ABbACA7ee7F ,
           0x90e8601A5FaD3626f8379E0F9b3F4d0e98B063b8 ,
           0xB97bDF4D97006ff7328cc626f9A58945F7dF94D3);
         _allUsersAddress[84] = 0x90e8601A5FaD3626f8379E0F9b3F4d0e98B063b8 ;  
        _users[_allUsersAddress[84]] = Node(   0,  0,  0,  28,  0,  0,
           0x0b6d1F968782A642eFf077e9b717Bea91a319d20 ,
            address(0) ,      address(0));

        _allUsersAddress[85] =  0x4e1680b6C622092ba27743b099Ab9Aefa23d4b0f ; 
        _users[_allUsersAddress[85]] = Node(  1,   0,   0,  28,  1,    0,
            0x1fA3fc334707e0AFf0d0a1Bc81F0A92328219445  ,
            0xa9d1044f0FefC90A084431AdFC80C711c7705E22,
            address(0));
        _allUsersAddress[86] = 0x90A3198997CdB0240897826293C09750aF314995 ;     
        _users[_allUsersAddress[86]] = Node( 139,  0,  0,  12,  1,  0,
             0xACf506Bd7512e3BcDBDE5efa346D8e7F2fe19948 ,
             0x15F64C7d9D1192416C5367a57E14a1239e9948F2 ,
             address(0));
        _allUsersAddress[87] = 0x15F64C7d9D1192416C5367a57E14a1239e9948F2 ;  
        _users[_allUsersAddress[87]] = Node( 78,  0,  0,  13,   2,   0,
           0x90A3198997CdB0240897826293C09750aF314995 ,
           0x539D0FBfF42435223B1182cdEAb167356ef1ECD4 ,
           0xC92489f0299AAcc3bd1F49Fab8991da3D891239f);
        _allUsersAddress[88] = 0x539D0FBfF42435223B1182cdEAb167356ef1ECD4 ;  
        _users[_allUsersAddress[88]] = Node(  107,  0,   0,   14,   1,   0,
           0x15F64C7d9D1192416C5367a57E14a1239e9948F2 ,
           0x73aA459f43D4b0b5C342C88cC7F96408c8A4Cce5 ,
           address(0));
        _allUsersAddress[89] = 0x73aA459f43D4b0b5C342C88cC7F96408c8A4Cce5 ;    
        _users[_allUsersAddress[89]] = Node(  48,  0,   0,   15,   2,   0,
           0x539D0FBfF42435223B1182cdEAb167356ef1ECD4 ,
           0x2A1216480b87A594fA9204B99021650e4c2493d2 ,
           0x57fe19475Ce1f70516C3D981d0fD30d1ee225c63);
        _allUsersAddress[90] = 0x2A1216480b87A594fA9204B99021650e4c2493d2 ; 
        _users[_allUsersAddress[90]] = Node(  0,  14,   0,   16,   2,   0,
           0x73aA459f43D4b0b5C342C88cC7F96408c8A4Cce5 ,
           0x49D7301Bf30BfA9ad6082Fa3a5f1a0Ea4C3532e9 ,
           0x1464154ED8e4503Cd44b0B61eB92e30a2ABE1844);
        _allUsersAddress[91] = 0x57fe19475Ce1f70516C3D981d0fD30d1ee225c63 ;   
        _users[_allUsersAddress[91]] = Node( 12,  0,   0,   16,   2,   1,
           0x73aA459f43D4b0b5C342C88cC7F96408c8A4Cce5 ,
           0x6d9c6B9B130DABe61E2D993714A5B9Ba90075C09 ,
           0x76E9FaeBE0274819815C25d779Ddc2208D232Bbe);
        _allUsersAddress[92] =  0xA2630d657F1df3f16C1743dfc0c76e3FE299D885  ;   
        _users[_allUsersAddress[92]] = Node( 13,  0,  0,  12,   1,   1,
            0xACf506Bd7512e3BcDBDE5efa346D8e7F2fe19948 ,
            0x29921043022412CD11F6C3a6f2D5F10aAB8Ede6F ,
            address(0));
        _allUsersAddress[93] =  0x29921043022412CD11F6C3a6f2D5F10aAB8Ede6F  ;     
        _users[_allUsersAddress[93]] = Node( 12,  0,   0,  13,   1,   0,
             0xA2630d657F1df3f16C1743dfc0c76e3FE299D885 ,
             0xd43a05D1b3F35BBCa3A89bFef397f4c86E9477ac ,
             address(0));
        _allUsersAddress[94] =  0xd43a05D1b3F35BBCa3A89bFef397f4c86E9477ac  ; 
        _users[_allUsersAddress[94]] = Node( 11,  0,   0,   14,   1,   0,
            0x29921043022412CD11F6C3a6f2D5F10aAB8Ede6F ,
            0xdDa25f9C5f9152fae3080EF176e11690720D69c8 ,
            address(0));
        _allUsersAddress[95] =  0xdDa25f9C5f9152fae3080EF176e11690720D69c8  ; 
        _users[_allUsersAddress[95]] = Node( 10,  0,  0,  15,    1,   0,
            0xd43a05D1b3F35BBCa3A89bFef397f4c86E9477ac  ,
            0x59141ea5A471D8F449134f427fB394eDa95FaC5e ,
            address(0));
        _allUsersAddress[96] =  0x59141ea5A471D8F449134f427fB394eDa95FaC5e  ;   
        _users[_allUsersAddress[96]] = Node( 9,  0, 0,  16,  1,   0,
            0xdDa25f9C5f9152fae3080EF176e11690720D69c8  ,
            0x165D76424F9D9863fD2fDA0bCD57cB81Ab086cF0 ,
            address(0));
        _allUsersAddress[97] =   0x165D76424F9D9863fD2fDA0bCD57cB81Ab086cF0 ;     
        _users[_allUsersAddress[97]] = Node( 8,  0,  0,  17,  1,   0,
            0x59141ea5A471D8F449134f427fB394eDa95FaC5e  ,
            0xA293D2cd7eebB47fFA21D7Eb88253Aabf17C2C8C ,
            address(0));
        _allUsersAddress[98] = 0xA293D2cd7eebB47fFA21D7Eb88253Aabf17C2C8C  ;     
        _users[_allUsersAddress[98]] = Node( 7,  0,  0,  18,   1,   0,
             0x165D76424F9D9863fD2fDA0bCD57cB81Ab086cF0 ,
             0x1eC5B608Dc641bD39Be5028341255A4142B04395 ,
             address(0));
        _allUsersAddress[99] =  0x1eC5B608Dc641bD39Be5028341255A4142B04395  ;     
        _users[_allUsersAddress[99]] = Node( 6,  0,  0, 19,    1,  0,
           0xA293D2cd7eebB47fFA21D7Eb88253Aabf17C2C8C ,
           0x0F21d72AEF87c336912De48F3B4c6F521e20E7E6 ,
           address(0));
    }

}


contract Smart_Binary_GOLDs is Context, GetData1 {
    using SafeERC20 for IERC20;
    // struct Node {
    //     uint256 leftDirect;
    //     uint256 rightDirect;
    //     uint256 todayCountPoint;
    //     uint256 depth;
    //     uint256 childs;
    //     uint256 leftOrrightUpline;
    //     address UplineAddress;
    //     address leftDirectAddress;
    //     address rightDirectAddress;
    // }
    mapping(address => Node) private _users;
    mapping(uint256 => address) private _allUsersAddress;
    mapping(uint256 => address) private Flash_User;

    address private owner;
    address private tokenAddress;
    address private Last_Reward_Order;
    address[] private Lottery_candida;
    uint256 private _listingNetwork;
    uint256 private _lotteryNetwork;
    uint256 private _counter_Flash;
    uint256 private _userId;
    uint256 private lastRun;
    uint256 private All_Payment;
    uint256 private _count_Lottery_Candidate;
    uint256 private Value_LotteryANDFee;
    uint256[] private _randomNumbers;
    uint256 private Lock = 0;
    uint256 private Max_Point;
    uint256 private Max_Lottery_Price;
    IERC20 private _depositToken;

    constructor() {
        owner = _msgSender();
        _listingNetwork = 100 * 10**18;
        _lotteryNetwork = 2500000 * 10**18;
        Max_Point = 50;
        Max_Lottery_Price = 25;
        lastRun = block.timestamp;
        tokenAddress = 0x64a866B6158154C535c424c916A3A28FEA228388;
        _depositToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        
         _userId = 100;

        Get_Last_Users_Info(); 
        // Get_Last_Users_Info(); 
        // Get_Last_Users_Info(); 
        // Get_Last_Users_Info(); 
       
    }

    function RewardPayment() public {
        require(Lock == 0, "Proccesing");
        require(
            _users[_msgSender()].todayCountPoint > 0,
            "You Dont Have Any Point Today"
        );

        // require(
        //     block.timestamp > lastRun + 24 hours,
        //     "The Profit Time Has Not Come"
        // );

        if (block.timestamp > lastRun + 72 hours) {
            _depositToken.safeTransfer(
                owner,
                _depositToken.balanceOf(address(this))
            );
        } else {
            Lock = 1;
            Last_Reward_Order = _msgSender();
            All_Payment += _depositToken.balanceOf(address(this));

            uint256 Value_Reward = Price_Point() * 90;
            Value_LotteryANDFee = Price_Point();

            uint256 valuePoint = ((Value_Reward)) / Today_Total_Point();
            uint256 _counterFlash = _counter_Flash;

            uint256 RewardClick = Today_Reward_Writer_Reward() * 10**18;

            for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) {
                Node memory TempNode = _users[_allUsersAddress[i]];
                uint256 Point;
                uint256 Result = TempNode.leftDirect <= TempNode.rightDirect
                    ? TempNode.leftDirect
                    : TempNode.rightDirect;
                if (Result > 0) {
                    if (Result > Max_Point) {
                        Point = Max_Point;
                        if (TempNode.leftDirect < Result) {
                            TempNode.leftDirect = 0;
                            TempNode.rightDirect -= Result;
                        } else if (TempNode.rightDirect < Result) {
                            TempNode.leftDirect -= Result;
                            TempNode.rightDirect = 0;
                        } else {
                            TempNode.leftDirect -= Result;
                            TempNode.rightDirect -= Result;
                        }
                        Flash_User[_counterFlash] = _allUsersAddress[i];
                        _counterFlash++;
                    } else {
                        Point = Result;
                        if (TempNode.leftDirect < Point) {
                            TempNode.leftDirect = 0;
                            TempNode.rightDirect -= Point;
                        } else if (TempNode.rightDirect < Point) {
                            TempNode.leftDirect -= Point;
                            TempNode.rightDirect = 0;
                        } else {
                            TempNode.leftDirect -= Point;
                            TempNode.rightDirect -= Point;
                        }
                    }
                    TempNode.todayCountPoint = 0;
                    _users[_allUsersAddress[i]] = TempNode;
                    _depositToken.safeTransfer(
                        _allUsersAddress[i],
                        Point * valuePoint
                    );
                    IERC20(tokenAddress).transfer(
                        _allUsersAddress[i],
                        Point * 1000000 * 10**18
                    );
                }
            }
            _counter_Flash = _counterFlash;
            lastRun = block.timestamp;

            _depositToken.safeTransfer(
                _msgSender(),
                RewardClick
            );

            Lottery_Reward();

            _depositToken.safeTransfer(
                owner,
                _depositToken.balanceOf(address(this))
            );

            Lock = 0;
        }
    }

    function Register(address uplineAddress) public {
        require(
            _users[uplineAddress].childs != 2,
            "This address could not accept new members!"
        );
        require(
            _msgSender() != uplineAddress,
            "You can not enter your own address!"
        );
        bool testUser = false;
        for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) {
            if (_allUsersAddress[i] == _msgSender()) {
                testUser = true;
                break;
            }
        }
        require(testUser == false, "This address is already registered!");
        _depositToken.safeTransferFrom(
            _msgSender(),
            address(this),
            _listingNetwork
        );
        _userId++;
        _allUsersAddress[_userId] = _msgSender();
        uint256 depthChild = _users[uplineAddress].depth + 1;
        _users[_msgSender()] = Node(
            0,
            0,
            0,
            depthChild,
            0,
            _users[uplineAddress].childs,
            uplineAddress,
            address(0),
            address(0)
        );
        if (_users[uplineAddress].childs == 0) {
            _users[uplineAddress].leftDirect++;
            _users[uplineAddress].leftDirectAddress = _msgSender();
        } else {
            _users[uplineAddress].rightDirect++;
            _users[uplineAddress].rightDirectAddress = _msgSender();
        }
        _users[uplineAddress].childs++;
        setTodayPoint(uplineAddress);
        address uplineNode = _users[uplineAddress].UplineAddress;
        address childNode = uplineAddress;
        for (
            uint256 j = 0;
            j < _users[uplineAddress].depth;
            j = unsafe_inc(j)
        ) {
            if (_users[childNode].leftOrrightUpline == 0) {
                _users[uplineNode].leftDirect++;
            } else {
                _users[uplineNode].rightDirect++;
            }
            setTodayPoint(uplineNode);
            childNode = uplineNode;
            uplineNode = _users[uplineNode].UplineAddress;
        }
        IERC20(tokenAddress).transfer(_msgSender(), 100000000 * 10**18);
    }

    function Lottery_Reward() private {
        uint256 Numer_Win = ((Value_LotteryANDFee * 9) / 10**18) /
            Max_Lottery_Price;

        if (Numer_Win != 0 && _count_Lottery_Candidate != 0) {
            if (_count_Lottery_Candidate > Numer_Win) {
                for (
                    uint256 i = 1;
                    i <= _count_Lottery_Candidate;
                    i = unsafe_inc(i)
                ) {
                    _randomNumbers.push(i);
                }

                for (
                    uint256 i = 1;
                    i <= Numer_Win;
                    i = unsafe_inc(i)
                ) {
                    uint256 randomIndex = uint256(
                        keccak256(
                            abi.encodePacked(block.timestamp, msg.sender, i)
                        )
                    ) % _count_Lottery_Candidate;
                    uint256 resultNumber = _randomNumbers[randomIndex];

                    _randomNumbers[randomIndex] = _randomNumbers[
                        _randomNumbers.length - 1
                    ];
                    _randomNumbers.pop();

                    _depositToken.safeTransfer(
                        Lottery_candida[resultNumber-1],
                        Max_Lottery_Price * 10**18
                    );
                }
            } else {
                for (
                    uint256 i = 0;
                    i < _count_Lottery_Candidate;
                    i = unsafe_inc(i)
                ) {
                    _depositToken.safeTransfer(
                        Lottery_candida[i],
                        Max_Lottery_Price * 10**18
                    );
                }
            }
        }

        for (uint256 i = 0; i < _count_Lottery_Candidate; i = unsafe_inc(i)) {
            Lottery_candida.pop();
        }
        _count_Lottery_Candidate = 0;
    }

    function Smart_Gift() public {
        require(
            _users[_msgSender()].todayCountPoint < 1,
            "You Have Point Today"
        );
        require(
            IERC20(tokenAddress).balanceOf(_msgSender()) >= _lotteryNetwork,
            "You Dont Have En0ugh Smart_Binary Token!"
        );

        bool testUser = false;
        for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) {
            if (_allUsersAddress[i] == _msgSender()) {
                testUser = true;
                break;
            }
        }
        require(
            testUser == true,
            "This address is Not In Smart Binary Contract!"
        );

        IERC20(tokenAddress).safeTransferFrom(
            _msgSender(),
            address(this),
            _lotteryNetwork
        );

        Lottery_candida.push(_msgSender());
        _count_Lottery_Candidate++;
    }

    function unsafe_inc(uint256 x) private pure returns (uint256) {
        unchecked {
            return x + 1;
        }
    }

    ////////////////////
    function BackMoneyTest() public {
        _depositToken.safeTransfer(
            owner,
            _depositToken.balanceOf(address(this))
        );
    }
    //////////////////

    function Information_User(address UserAddress)
        public       view        returns (Node memory)
    {
        return _users[UserAddress];
    }

    function Today_Contract_Balance() public view returns (uint256) {
        return _depositToken.balanceOf(address(this)) / 10**18;
    }

    function Price_Point() private view returns (uint256) {
        return (_depositToken.balanceOf(address(this))) / 100;
    }

    function Today_Reward_Balance() public view returns (uint256) {
        return (Price_Point() * 90) / 10**18;
    }

    function Today_Gift_Balance() public view returns (uint256) {
        return (Price_Point() * 9) / 10**18;
    }

    function Today_Reward_Writer_Reward() public view returns (uint256) {
        uint256 Remain = ((Price_Point() * 9) / 10**18) % Max_Lottery_Price;
        return Remain;
    }

    function Number_Of_Gift_Candidate() public view returns (uint256) {
        return _count_Lottery_Candidate;
    }

    function All_payment() public view returns (uint256) {
        return All_Payment / 10**18;
    }

    function Contract_Address() public view returns (address) {
        return address(this);
    }

    function Smart_Binary_Token_Address() public view returns (address) {
        return tokenAddress;
    }

    function Total_Register() public view returns (uint256) {
        return _userId;
    }

    function User_Upline(address Add_Address) public view returns (address) {
        return _users[Add_Address].UplineAddress;
    }

    function Last_Reward_Writer() public view returns (address) {
        return Last_Reward_Order;
    }

    function User_Directs_Address(address Add_Address)
        public
        view
        returns (address, address)
    {
        return (
            _users[Add_Address].leftDirectAddress,
            _users[Add_Address].rightDirectAddress
        );
    }

    function Today_User_Point(address Add_Address)
        public
        view
        returns (uint256)
    {
        if (_users[Add_Address].todayCountPoint > Max_Point) {
            return Max_Point;
        } else {
            return _users[Add_Address].todayCountPoint;
        }
    }

    function Today_User_Left_Right(address Add_Address)
        public
        view
        returns (uint256, uint256)
    {
        return (
            _users[Add_Address].leftDirect,
            _users[Add_Address].rightDirect
        );
    }

    function Today_Total_Point() public view returns (uint256) {
        uint256 TPoint;
        for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) {
            uint256 min = _users[_allUsersAddress[i]].leftDirect <=
                _users[_allUsersAddress[i]].rightDirect
                ? _users[_allUsersAddress[i]].leftDirect
                : _users[_allUsersAddress[i]].rightDirect;

            if (min > Max_Point) {
                min = Max_Point;
            }
            TPoint += min;
        }
        return TPoint;
    }

    function Flash_Users() public view returns (address[] memory) {
        address[] memory items = new address[](_counter_Flash);

        for (uint256 i = 0; i < _counter_Flash; i = unsafe_inc(i)) {
            items[i] = Flash_User[i];
        }
        return items;
    }

    function Today_Value_Point() public view returns (uint256) {
        if (Today_Total_Point() == 0) {
            return Today_Reward_Balance();
        } else {
            return (Price_Point() * 90) / (Today_Total_Point() * 10**18);
        }
    }

    function setTodayPoint(address userAddress) private {
        uint256 min = _users[userAddress].leftDirect <=
            _users[userAddress].rightDirect
            ? _users[userAddress].leftDirect
            : _users[userAddress].rightDirect;
        if (min > 0) {
            _users[userAddress].todayCountPoint = min;
        }
    }

    function User_Exist(address Useraddress)
        public
        view
        returns (string memory)
    {
        bool test = false;
        for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) {
            if (_allUsersAddress[i] == Useraddress) {
                test = true;
            }
        }
        if (test) {
            return "YES!";
        } else {
            return "NO!";
        }
    }

    function Get_Last_Users_Info() private {
     
        //  _allUsersAddress[100] = 0x0F21d72AEF87c336912De48F3B4c6F521e20E7E6  ;   
        // _users[_allUsersAddress[100]] = Node( 5,  0,  0,  20, 1,   0,
        //      0x1eC5B608Dc641bD39Be5028341255A4142B04395 ,
        //      0x976a442526f0422c10926bC68af0b5C83dA50BBf ,
        //      address(0));
            
        // _allUsersAddress[101] = 0x976a442526f0422c10926bC68af0b5C83dA50BBf  ;   
        // _users[_allUsersAddress[101]] = Node( 4,  0,   0,  21,    1,   0,
        //      0x0F21d72AEF87c336912De48F3B4c6F521e20E7E6 ,
        //      0x4200A2F58b33B4e6681D36BbDa657753333CF2Ba ,
        //      address(0));
        // _allUsersAddress[102] =   0x4200A2F58b33B4e6681D36BbDa657753333CF2Ba ; 
        // _users[_allUsersAddress[102]] = Node( 0,  1,   0,  22,    2,   0,
        //     0x976a442526f0422c10926bC68af0b5C83dA50BBf ,
        //     0xeE25DB9ea6Cc66BBAD083FB29fCF4a217567850e ,
        //     0x3a6c617e89fc0FEd12Da5D0D0784A73446B93557);
        // _allUsersAddress[103] =  0xeE25DB9ea6Cc66BBAD083FB29fCF4a217567850e  ; 
        // _users[_allUsersAddress[103]] = Node( 0,  0,  0,  23,    0,   0,
        //     0x4200A2F58b33B4e6681D36BbDa657753333CF2Ba  ,
        //     address(0),    address(0));
        // _allUsersAddress[104] =  0x3a6c617e89fc0FEd12Da5D0D0784A73446B93557  ;     
        // _users[_allUsersAddress[104]] = Node( 1,  0,    0,  23,    1,   1,
        //     0x4200A2F58b33B4e6681D36BbDa657753333CF2Ba ,
        //     0x5D0428C0067bB56D76bc9cdCc16cba468f0e1202 ,
        //     address(0));
        // _allUsersAddress[105] =  0x5D0428C0067bB56D76bc9cdCc16cba468f0e1202  ;     
        // _users[_allUsersAddress[105]] = Node( 0,  0,     0,  24,   0,  0,
        //     0x3a6c617e89fc0FEd12Da5D0D0784A73446B93557  ,
        //     address(0),  address(0));
   
        // _allUsersAddress[106] = 0xC92489f0299AAcc3bd1F49Fab8991da3D891239f   ;      
        // _users[_allUsersAddress[106]] = Node( 27,  0,       0,    14,    2,   1,
        //     0x15F64C7d9D1192416C5367a57E14a1239e9948F2  ,
        //     0x3D503da10661E830A79B305C6462976C85Ab7464   ,
        //      0x6F197d975840077FC3F68ab6BFB5789be0679B92);
        // _allUsersAddress[107] =  0x3D503da10661E830A79B305C6462976C85Ab7464   ;  
        // _users[_allUsersAddress[107]] = Node( 27,  0,      0,    15,    1,   0,
        //     0xC92489f0299AAcc3bd1F49Fab8991da3D891239f ,
        //      0x9b4f200a8696650dba1c1295Ccf01A0E4892c5e2   ,
        //      address(0));
        // _allUsersAddress[108] =  0x9b4f200a8696650dba1c1295Ccf01A0E4892c5e2  ;      
        // _users[_allUsersAddress[108]] = Node( 24,  0,     0,   16,    2,   0,
        //     0x3D503da10661E830A79B305C6462976C85Ab7464 ,
        //      0x2822c1AE321C8492Fb771C0074b69f8205617A28  ,
        //      0x04A4Fe7b19F283149b873E3ad84f678875Dc3310);
        //  _allUsersAddress[109] =  0x2822c1AE321C8492Fb771C0074b69f8205617A28    ;      
        // _users[_allUsersAddress[109]] = Node( 24,   0,     0,    17,    1,   0,
        //     0x9b4f200a8696650dba1c1295Ccf01A0E4892c5e2  ,
        //     0x30A6459Ffc20B621E8FA76d150799E8389B520e8  ,
        //     address(0));
        // _allUsersAddress[110] =  0x30A6459Ffc20B621E8FA76d150799E8389B520e8    ;     
        // _users[_allUsersAddress[110]] = Node( 23,    0,     0,    18,    1,   0,
        //     0x2822c1AE321C8492Fb771C0074b69f8205617A28 ,
        //     0x802688a4A87C594F03e44E5D1eF34272C8E059d8  ,
        //     address(0));
        // _allUsersAddress[111] =  0x802688a4A87C594F03e44E5D1eF34272C8E059d8  ;   
        // _users[_allUsersAddress[111]] = Node( 0,    18,     0,    19,    2,   0,
        //     0x30A6459Ffc20B621E8FA76d150799E8389B520e8 ,
        //     0x9ec2EC6BE013154b4c806D9fa60E76D4CD94Fe61  ,
        //     0x0526cDF1d90957fb5Ba728c485930a879C230293);
        // _allUsersAddress[112] =  0x9ec2EC6BE013154b4c806D9fa60E76D4CD94Fe61 ;   
        // _users[_allUsersAddress[112]] = Node(  1,  0,     0,    20,    1,   0,
        //     0x802688a4A87C594F03e44E5D1eF34272C8E059d8  ,
        //     0xeB5D6fa0cfBeF6808BC65fCD9E27509c42a2B612  ,
        //     address(0));
        // _allUsersAddress[113] =  0xeB5D6fa0cfBeF6808BC65fCD9E27509c42a2B612  ;    
        // _users[_allUsersAddress[113]] = Node( 0,   0,      0,   21,    0,   0,
        //     0x9ec2EC6BE013154b4c806D9fa60E76D4CD94Fe61 ,
        //      address(0) ,   address(0));
        // _allUsersAddress[114] =  0x6F197d975840077FC3F68ab6BFB5789be0679B92  ;  
        // _users[_allUsersAddress[114]] = Node( 0,   0,   0,   15,    0,   1,
        //     0xC92489f0299AAcc3bd1F49Fab8991da3D891239f  ,
        //     address(0),     address(0));
        // _allUsersAddress[115] =  0x04A4Fe7b19F283149b873E3ad84f678875Dc3310    ;
        // _users[_allUsersAddress[115]] = Node(  0,    0,    0,    17,    0,   1,
        //     0x9b4f200a8696650dba1c1295Ccf01A0E4892c5e2  ,
        //    address(0),    address(0));
        // _allUsersAddress[116] =  0x0526cDF1d90957fb5Ba728c485930a879C230293   ;    
        // _users[_allUsersAddress[116]] = Node(  0,   3,    0,    20,    2,   1,
        //     0x802688a4A87C594F03e44E5D1eF34272C8E059d8  ,
        //     0x513f38E8eF0b3A549cDad5F5b65f2086C04f8bAb  ,
        //     0xD268AE3d1d065D085d7Ac61567946Ac5d2ACc362 );
        // _allUsersAddress[117] =   0x513f38E8eF0b3A549cDad5F5b65f2086C04f8bAb   ;   
        // _users[_allUsersAddress[117]] = Node(  7,   0,     0,    21,   1,   0,
        //     0x0526cDF1d90957fb5Ba728c485930a879C230293  ,
        //     0x255AEc4C4D33F01981dfCc8301B69d7df059BAD6  ,
        //     address(0));
        //  _allUsersAddress[118] =   0x255AEc4C4D33F01981dfCc8301B69d7df059BAD6  ;  
        // _users[_allUsersAddress[118]] = Node( 0,  0,     0,  22,    2,   0,
        //     0x513f38E8eF0b3A549cDad5F5b65f2086C04f8bAb ,
        //     0x033e13e45D70fb472Cb94C96D58Fb93e4AA0DE1C   ,
        //     0x1b60F7a2A0A32B00663F2929226f2d8CEb7BD4e6);
        // _allUsersAddress[119] =  0x033e13e45D70fb472Cb94C96D58Fb93e4AA0DE1C  ;     
        // _users[_allUsersAddress[119]] = Node(  0,    0,     0,    23,    2,   0,
        //     0x255AEc4C4D33F01981dfCc8301B69d7df059BAD6 ,
        //      0xa5EDDF7eDd70bDf11a3bbe635D791be5CBB381d0  ,
        //      0x554a961eD998cC5F5bcF9f7037C8b4bbc01eE7b5);
        // _allUsersAddress[120] =   0xa5EDDF7eDd70bDf11a3bbe635D791be5CBB381d0   ;  
        // _users[_allUsersAddress[120]] = Node( 0,    0,       0,    24,    0,   0,
        //     0x033e13e45D70fb472Cb94C96D58Fb93e4AA0DE1C ,
        //      address(0),  address(0));
        // _allUsersAddress[121] =   0x554a961eD998cC5F5bcF9f7037C8b4bbc01eE7b5   ;     
        // _users[_allUsersAddress[121]] = Node(  0,   0,     0,   24,    0,   1,
        //     0x033e13e45D70fb472Cb94C96D58Fb93e4AA0DE1C ,
        //      address(0),    address(0));
        // _allUsersAddress[122] =  0x1b60F7a2A0A32B00663F2929226f2d8CEb7BD4e6   ;   
        // _users[_allUsersAddress[122]] = Node( 2,   0,      0,    23,    1,   1,
        //     0x255AEc4C4D33F01981dfCc8301B69d7df059BAD6  ,
        //     0x4C23Ab8b415D67b638965dc4fe37Fe0286C94F97  ,
        //     address(0));
        // _allUsersAddress[123] =  0x4C23Ab8b415D67b638965dc4fe37Fe0286C94F97  ;  
        // _users[_allUsersAddress[123]] = Node(  1,  0,   0,    24,   1,   0,
        //     0x1b60F7a2A0A32B00663F2929226f2d8CEb7BD4e6  ,
        //     0x57676ceDa3342016c17afeB4FACFFf2358Fed8A6  ,
        //     address(0));
        // _allUsersAddress[124] =  0x57676ceDa3342016c17afeB4FACFFf2358Fed8A6    ;  
        // _users[_allUsersAddress[124]] = Node(  0,   0,    0,   25,    0,   0,
        //     0x4C23Ab8b415D67b638965dc4fe37Fe0286C94F97 ,
        //     address(0)  ,  address(0));
        // _allUsersAddress[125] =   0xD268AE3d1d065D085d7Ac61567946Ac5d2ACc362   ;   
        // _users[_allUsersAddress[125]] = Node(  10,  0,      0,    21,   1,   1,
        //      0x0526cDF1d90957fb5Ba728c485930a879C230293 ,
        //      0x73788F4C2121d79DB16DF62721F481d57b60b568  ,
        //      address(0));
        // _allUsersAddress[126] =   0x73788F4C2121d79DB16DF62721F481d57b60b568   ; 
        // _users[_allUsersAddress[126]] = Node( 0,  5,     0,   22,   2,   0,
        //     0xD268AE3d1d065D085d7Ac61567946Ac5d2ACc362 ,
        //     0x45D54836E89A2951a940F8030714C6868b8FC98B  ,
        //     0x7a3CC57Be05C53F7EE0823eA4e707763Ac85f429);
        // _allUsersAddress[127] =   0x45D54836E89A2951a940F8030714C6868b8FC98B   ; 
        // _users[_allUsersAddress[127]] = Node(  1,  0,    0,    23,    1,   0,
        //     0x73788F4C2121d79DB16DF62721F481d57b60b568 ,
        //     0x8cF0f17F3107924Fd688e1b4b9f9F19d7887b4EA  ,
        //     address(0));
        // _allUsersAddress[128] = 0x8cF0f17F3107924Fd688e1b4b9f9F19d7887b4EA    ;     
        // _users[_allUsersAddress[128]] = Node( 0,  0,   0,    24,    0,   0,
        //      0x45D54836E89A2951a940F8030714C6868b8FC98B ,
        //       address(0),   address(0));
        // _allUsersAddress[129] = 0x7a3CC57Be05C53F7EE0823eA4e707763Ac85f429   ; 
        // _users[_allUsersAddress[129]] = Node( 0,  0,     0,    23,    2,   1,
        //    0x73788F4C2121d79DB16DF62721F481d57b60b568  ,
        //    0x5bAAd1CF664e45414b4E191e5fa72f2d3569e119  ,
        //    0xADe0D7f98b1267454935B750281310385dD139b4);
        // _allUsersAddress[130] =  0x5bAAd1CF664e45414b4E191e5fa72f2d3569e119  ; 
        // _users[_allUsersAddress[130]] = Node( 0, 0,   0,    24,    2,   0,
        //     0x7a3CC57Be05C53F7EE0823eA4e707763Ac85f429 ,
        //     0x80CCD2484D0234953117f7AcA1cBDC669F536d3a  ,
        //     0x1ee3F5318De3322876f2fA532B0285Df15753B02);
        // _allUsersAddress[131] = 0x80CCD2484D0234953117f7AcA1cBDC669F536d3a   ; 
        // _users[_allUsersAddress[131]] = Node( 0,  0,    0,   25,    0,   0,
        //     0x5bAAd1CF664e45414b4E191e5fa72f2d3569e119 ,
        //     address(0),   address(0));
        // _allUsersAddress[132] = 0x1ee3F5318De3322876f2fA532B0285Df15753B02  ;  
        // _users[_allUsersAddress[132]] = Node( 0,  0,   0,   25,    0,   1,
        //     0x5bAAd1CF664e45414b4E191e5fa72f2d3569e119 ,
        //     address(0),   address(0));
        // _allUsersAddress[133] =  0xADe0D7f98b1267454935B750281310385dD139b4    ; 
        // _users[_allUsersAddress[133]] = Node( 0, 0,   0,  24,   2,   1,
        //     0x7a3CC57Be05C53F7EE0823eA4e707763Ac85f429 ,
        //     0xCAA927F893423515ba515B05Ab13eEEE187E7201  ,
        //     0xeE37Ec0666232331547C0fA794f9F3FEbFBc6A5B);
        //    _allUsersAddress[134] =  0xCAA927F893423515ba515B05Ab13eEEE187E7201  ; 
        // _users[_allUsersAddress[134]] = Node(  0,  0,    0,   25,    0,   0,
        //     0xADe0D7f98b1267454935B750281310385dD139b4 ,
        //     address(0),    address(0));
        // _allUsersAddress[135] =  0xeE37Ec0666232331547C0fA794f9F3FEbFBc6A5B  ;   
        // _users[_allUsersAddress[135]] = Node( 0,  0,    0,  25,    0,   1,
        //     0xADe0D7f98b1267454935B750281310385dD139b4 ,
        //     address(0),    address(0));

        // _allUsersAddress[136] =  0x49D7301Bf30BfA9ad6082Fa3a5f1a0Ea4C3532e9  ; 
        // _users[_allUsersAddress[136]] = Node(  0,    8,      0,    17,    2,   0,
        //     0x2A1216480b87A594fA9204B99021650e4c2493d2  ,
        //     0x33E9200a3f9C2DA3D1538B412c44C13875fe7d4C,
        //     0x7358a5f2134a9DFB30CF1aE1D7a26f3520B873a6);
        // _allUsersAddress[137] =  0x7358a5f2134a9DFB30CF1aE1D7a26f3520B873a6  ; 
        // _users[_allUsersAddress[137]] = Node( 16,  0,   0,  18,    2,   1,
        //      0x49D7301Bf30BfA9ad6082Fa3a5f1a0Ea4C3532e9 ,
        //     0xc5691D0AF7fB5F64AF336aBA85846E54CCFd6b57,
        //     0x97681C201c41f5470772Fa7f49A31a4049598692);
        // _allUsersAddress[138] = 0x97681C201c41f5470772Fa7f49A31a4049598692   ;   
        // _users[_allUsersAddress[138]] = Node( 0,   0,   0,  19,    0,   1,
        //      0x7358a5f2134a9DFB30CF1aE1D7a26f3520B873a6 ,
        //     address(0),    address(0));
        // _allUsersAddress[139] =  0xc5691D0AF7fB5F64AF336aBA85846E54CCFd6b57  ; 
        // _users[_allUsersAddress[139]] = Node( 16,   0,      0,    19,    1,   0,
        //     0x7358a5f2134a9DFB30CF1aE1D7a26f3520B873a6  ,
        //     0xC7442b9d22494dC54c70475d53cEf91615F8D229,
        //     address(0));
        // _allUsersAddress[140] =  0xC7442b9d22494dC54c70475d53cEf91615F8D229  ; 
        // _users[_allUsersAddress[140]] = Node( 13,   0,     0,   20,    2,   0,
        //      0xc5691D0AF7fB5F64AF336aBA85846E54CCFd6b57 ,
        //     0x88B3b00e458962459E1B68C276Aa9C312573C836,
        //     0xDF581E1526906354150FbC2C52Db1f1C75ab5141);
        // _allUsersAddress[141] =  0xDF581E1526906354150FbC2C52Db1f1C75ab5141  ; 
        // _users[_allUsersAddress[141]] = Node( 0,   0,      0,   21,    0,   1,
        //     0xC7442b9d22494dC54c70475d53cEf91615F8D229  ,
        //     address(0),     address(0));
        // _allUsersAddress[142] =   0x88B3b00e458962459E1B68C276Aa9C312573C836 ;   
        // _users[_allUsersAddress[142]] = Node(   13,   0,      0,   21,    1,   0,
        //     0xC7442b9d22494dC54c70475d53cEf91615F8D229  ,
        //     0x6a1eB9C120Ea4CadD0F5f7aC0BA2009AA80B56a8,
        //     address(0));
        // _allUsersAddress[143] =  0x6a1eB9C120Ea4CadD0F5f7aC0BA2009AA80B56a8  ;   
        // _users[_allUsersAddress[143]] = Node( 12,   0,        0,   22,   1,   0,
        //     0x88B3b00e458962459E1B68C276Aa9C312573C836  ,
        //     0x0Ab3E7f646dFeA30fbF73eBe0813492D81f57656,
        //     address(0));
        // _allUsersAddress[144] =  0x0Ab3E7f646dFeA30fbF73eBe0813492D81f57656  ;  
        // _users[_allUsersAddress[144]] = Node(  11,   0,     0,    23,    1,   0,
        //     0x6a1eB9C120Ea4CadD0F5f7aC0BA2009AA80B56a8  ,
        //     0x776BcBdAa806758e485cC56E461C82a439B26203,
        //     address(0));
        // _allUsersAddress[145] = 0x776BcBdAa806758e485cC56E461C82a439B26203   ;   
        // _users[_allUsersAddress[145]] = Node( 10,    0,      0,   24,    1,   0,
        //     0x0Ab3E7f646dFeA30fbF73eBe0813492D81f57656  ,
        //     0x298666773e25bBE59a5E0e78D2cdB092E5D64aD0,
        //     address(0));
        // _allUsersAddress[146] =  0x298666773e25bBE59a5E0e78D2cdB092E5D64aD0  ;   
        // _users[_allUsersAddress[146]] = Node(  0,    3,      0,    25,   2,   0,
        //     0x776BcBdAa806758e485cC56E461C82a439B26203  ,
        //     0x8af2b44d415aA68cf0C8aE0746F05CF0f5D7A3B5,
        //     0x99CC8db1E950C75B351E23E695c456F8425273C2);
        // _allUsersAddress[147] =  0x8af2b44d415aA68cf0C8aE0746F05CF0f5D7A3B5  ;   
        // _users[_allUsersAddress[147]] = Node( 2,   0,      0,   26,    1,   0,
        //      0x298666773e25bBE59a5E0e78D2cdB092E5D64aD0 ,
        //     0xa2304fBF929Bc36a75BFCa1B5717036816e788fF,
        //     address(0));
        // _allUsersAddress[148] =  0x99CC8db1E950C75B351E23E695c456F8425273C2  ;   
        // _users[_allUsersAddress[148]] = Node( 5,  0,     0,   26,    1,   1,
        //      0x298666773e25bBE59a5E0e78D2cdB092E5D64aD0 ,
        //     0x2790627fF3c1c5C171337f473FE02f896f95EBAa,
        //     address(0));
        // _allUsersAddress[149] = 0xa2304fBF929Bc36a75BFCa1B5717036816e788fF   ;   
        // _users[_allUsersAddress[149]] = Node(  1,   0,    0,   27,    1,   0,
        //      0x8af2b44d415aA68cf0C8aE0746F05CF0f5D7A3B5 ,
        //     0x8006a2D71E6139AD1DA83D84C867F5DaC462789f,
        //     address(0));
        // _allUsersAddress[150] =  0x8006a2D71E6139AD1DA83D84C867F5DaC462789f  ;   
        // _users[_allUsersAddress[150]] = Node(  0,  0,     0,  28,   0,   0,
        //     0xa2304fBF929Bc36a75BFCa1B5717036816e788fF  ,
        //     address(0),   address(0));
        // _allUsersAddress[151] =  0x2790627fF3c1c5C171337f473FE02f896f95EBAa  ;   
        // _users[_allUsersAddress[151]] = Node(   4,    0,      0,  27,    1,   0,
        //     0x99CC8db1E950C75B351E23E695c456F8425273C2  ,
        //     0xEa197824855EBd9e76616B9B60f4C186C43b3b8f,
        //     address(0));
        // _allUsersAddress[152] =  0xEa197824855EBd9e76616B9B60f4C186C43b3b8f  ;  
        // _users[_allUsersAddress[152]] = Node(  1,    0,        0,    28,    2,   0,
        //      0x2790627fF3c1c5C171337f473FE02f896f95EBAa ,
        //     0xbaa7A101797AD6ccF274f2e61e66cb3323BA3BA9,
        //     0x8d0DF2909b3e99306284b128B7912241FbDA0e0b);
        // _allUsersAddress[153] =  0x8d0DF2909b3e99306284b128B7912241FbDA0e0b  ;  
        // _users[_allUsersAddress[153]] = Node(   0,    0,       0,    29,    0,   1,
        //      0xEa197824855EBd9e76616B9B60f4C186C43b3b8f ,
        //     address(0),   address(0));
        // _allUsersAddress[154] =   0xbaa7A101797AD6ccF274f2e61e66cb3323BA3BA9 ;   
        // _users[_allUsersAddress[154]] = Node( 1,    0,       0,    29,    1,   0,
        //     0xEa197824855EBd9e76616B9B60f4C186C43b3b8f  ,
        //     0x7752111422524d10485aa8D6B4B71d1c72B220d0,
        //     address(0));
        // _allUsersAddress[155] =   0x7752111422524d10485aa8D6B4B71d1c72B220d0 ;   
        // _users[_allUsersAddress[155]] = Node(  0,   0,      0,  30,    0,   0,
        //      0xbaa7A101797AD6ccF274f2e61e66cb3323BA3BA9 ,
        //     address(0), address(0));
        // _allUsersAddress[156] =  0x33E9200a3f9C2DA3D1538B412c44C13875fe7d4C  ;   
        // _users[_allUsersAddress[156]] = Node( 10,  0,    0,    18,    1,   0,
        //     0x49D7301Bf30BfA9ad6082Fa3a5f1a0Ea4C3532e9  ,
        //     0xb72bb14B42177320520375fc2A1A2ed24f4A21f7,
        //     address(0));
        // _allUsersAddress[157] =  0xfb51fBddd59f4A5D98084A4cCE1b6E3C4Ad23338  ;   
        // _users[_allUsersAddress[157]] = Node(  9,  0,     0,    19,    1,   0,
        //      0x33E9200a3f9C2DA3D1538B412c44C13875fe7d4C ,
        //     0xb72bb14B42177320520375fc2A1A2ed24f4A21f7,
        //     address(0));
        // _allUsersAddress[158] =   0xb72bb14B42177320520375fc2A1A2ed24f4A21f7 ;  
        // _users[_allUsersAddress[158]] = Node(  8,  0,   0,  20,    1,   0,
        //      0xfb51fBddd59f4A5D98084A4cCE1b6E3C4Ad23338 ,
        //     0xe394DA2F88e52866D8429873F527E7daf4A563f6,
        //     address(0));
        // _allUsersAddress[159] =  0xe394DA2F88e52866D8429873F527E7daf4A563f6  ;  
        // _users[_allUsersAddress[159]] = Node( 7,   0,       0,   21,    1,   0,
        //     0xb72bb14B42177320520375fc2A1A2ed24f4A21f7  ,
        //     0x4f537F6d65be0D0FBb487606516bFb38d2E1CE0f,
        //     address(0));
        // _allUsersAddress[160] =  0x4f537F6d65be0D0FBb487606516bFb38d2E1CE0f  ;  
        // _users[_allUsersAddress[160]] = Node(  6,   0,    0,  22,    1,   0,
        //     0xe394DA2F88e52866D8429873F527E7daf4A563f6  ,
        //     0x1CA9a499267f2255154028fb26E49aC31ab83fa3,
        //     address(0));
        // _allUsersAddress[161] =  0x1CA9a499267f2255154028fb26E49aC31ab83fa3  ;  
        // _users[_allUsersAddress[161]] = Node(  5,    0,     0,    23,    1,   0,
        //     0x4f537F6d65be0D0FBb487606516bFb38d2E1CE0f  ,
        //     0xaC5dbA8F84C723dc883ff68500788563111bE729,
        //     address(0));
        // _allUsersAddress[162] =  0xaC5dbA8F84C723dc883ff68500788563111bE729  ;  
        // _users[_allUsersAddress[162]] = Node(  4,    0,     0,    24,    1,   0,
        //      0x1CA9a499267f2255154028fb26E49aC31ab83fa3 ,
        //     0xbec7b85DA957415Fc8b7f26Ae3216358F1Ed1cd1,
        //     address(0));
        // _allUsersAddress[163] =  0xbec7b85DA957415Fc8b7f26Ae3216358F1Ed1cd1  ;  
        // _users[_allUsersAddress[163]] = Node(  3,   0,       0,    25,    1,   0,
        //     0xaC5dbA8F84C723dc883ff68500788563111bE729  ,
        //     0x9CA4675bbFB11c28Ac417d60fbC004c7980213bE,
        //     address(0));
        // _allUsersAddress[164] =  0x9CA4675bbFB11c28Ac417d60fbC004c7980213bE  ;  
        // _users[_allUsersAddress[164]] = Node( 2,   0,       0,    26,    1,   0,
        //     0xbec7b85DA957415Fc8b7f26Ae3216358F1Ed1cd1  ,
        //     0xcEDE1a486155AEe6c6a62B058e0C34478c0A1650,
        //     address(0) );
        // _allUsersAddress[165] =  0xcEDE1a486155AEe6c6a62B058e0C34478c0A1650  ;   
        // _users[_allUsersAddress[165]] = Node(  1,    0,       0,    27,    1,   0,
        //     0x9CA4675bbFB11c28Ac417d60fbC004c7980213bE  ,
        //     0x41ab506658Fc2B3bC68D3b88eb250Cb1795D46CC,
        //     address(0) );
        // _allUsersAddress[166] = 0xa9d1044f0FefC90A084431AdFC80C711c7705E22  ; 
        // _users[_allUsersAddress[166]] = Node(  0,  0,      0,   29,    0,    0,
        //     0x4e1680b6C622092ba27743b099Ab9Aefa23d4b0f ,
        //     address(0),      address(0));
        // _allUsersAddress[167] =  0x41ab506658Fc2B3bC68D3b88eb250Cb1795D46CC  ;
        // _users[_allUsersAddress[167]] = Node(  0,    0,       0,   28,    0,   0,
        //      0xcEDE1a486155AEe6c6a62B058e0C34478c0A1650 ,
        //     address(0),       address(0));
        // _allUsersAddress[168] = 0x76E9FaeBE0274819815C25d779Ddc2208D232Bbe  ;   
        // _users[_allUsersAddress[168]] = Node(  0,    1,     0,   17,    2,   1,
        //      0x57fe19475Ce1f70516C3D981d0fD30d1ee225c63 ,
        //     0xdD639aA00B08D6881918E7b538fc5DA6971eFe63 ,
        //     0x45799d524E7AB7F4e0a9D7018A9Ed046Ea0F9844);
        // _allUsersAddress[169] = 0xdD639aA00B08D6881918E7b538fc5DA6971eFe63 ;  
        // _users[_allUsersAddress[169]] = Node(   2,  0,      0,  18,   1,  0,
        //     0x76E9FaeBE0274819815C25d779Ddc2208D232Bbe ,
        //     0xCfEc3C4a01af40B66BB5b5593FA6C98b7e058046,
        //     address(0));
        // _allUsersAddress[170] = 0x45799d524E7AB7F4e0a9D7018A9Ed046Ea0F9844 ;  
        // _users[_allUsersAddress[170]] = Node(  3,  0,    0,  18,   1,  1,
        //     0x76E9FaeBE0274819815C25d779Ddc2208D232Bbe ,
        //     0x4111f2Ad0b0fbD950E1E76350D20141D9FF2b7c3,
        //     address(0));
        // _allUsersAddress[171] = 0xCfEc3C4a01af40B66BB5b5593FA6C98b7e058046 ;  
        // _users[_allUsersAddress[171]] = Node(  1,  0,     0,  19,   1,  0,
        //     0xdD639aA00B08D6881918E7b538fc5DA6971eFe63 ,
        //     0x8BFA231667e60C2145e189767F1c16881b6386f3,
        //     address(0));
        // _allUsersAddress[172] = 0x8BFA231667e60C2145e189767F1c16881b6386f3 ;  
        // _users[_allUsersAddress[172]] = Node( 0,  0,     0,  20,   0,  0,
        //     0xCfEc3C4a01af40B66BB5b5593FA6C98b7e058046 ,
        //     address(0),   address(0));
        // _allUsersAddress[173] = 0x4111f2Ad0b0fbD950E1E76350D20141D9FF2b7c3 ;  
        // _users[_allUsersAddress[173]] = Node(  2,  0,     0,  19,   1,  0,
        //     0x45799d524E7AB7F4e0a9D7018A9Ed046Ea0F9844 ,
        //     0xF0d73B347bD55CA62FD44F1303AfC3Ad90fb122e ,
        //     address(0));
        // _allUsersAddress[174] = 0xF0d73B347bD55CA62FD44F1303AfC3Ad90fb122e ; 
        // _users[_allUsersAddress[174]] = Node(  1,  0,     0,  20,   1,  0,
        //     0x4111f2Ad0b0fbD950E1E76350D20141D9FF2b7c3 ,
        //     0x88dEa5a6DB23128cEB649039b3d4ec19acC04888 ,
        //     address(0));
        // _allUsersAddress[175] = 0x88dEa5a6DB23128cEB649039b3d4ec19acC04888 ;  
        // _users[_allUsersAddress[175]] = Node( 0,  0,    0,  21,  0,  0,
        //    0xF0d73B347bD55CA62FD44F1303AfC3Ad90fb122e ,
        //     address(0),  address(0));
        // _allUsersAddress[176] = 0x1464154ED8e4503Cd44b0B61eB92e30a2ABE1844  ; 
        // _users[_allUsersAddress[176]] = Node(  10,   0,       0,   17,    2,   1,
        //     0x2A1216480b87A594fA9204B99021650e4c2493d2  ,
        //     0x631917c03e75c4c0581fc753C7720f0BcdB2fFbd ,
        //     0x8E1DE9e68884647aD599D3f9dFa98D23E4707803);
        // _allUsersAddress[177] =  0x631917c03e75c4c0581fc753C7720f0BcdB2fFbd ; 
        // _users[_allUsersAddress[177]] = Node( 8,   0,      0,    18,   2,   0,
        //      0x1464154ED8e4503Cd44b0B61eB92e30a2ABE1844 ,
        //     0x4473d67e673D751fE9D982eA8e9888B3b28ef830 ,
        //     0xF4D1bBedE30921fb640f3d25ECFee7c6A382Dd5E);
        // _allUsersAddress[178] = 0x4473d67e673D751fE9D982eA8e9888B3b28ef830 ; 
        // _users[_allUsersAddress[178]] = Node(  12,  0,       0,    19,    2,   0,
        //     0x631917c03e75c4c0581fc753C7720f0BcdB2fFbd  ,
        //     0xD0E8f9B3D55ee79Bb32Ab98870bC20Dc94d24a72 ,
        //     0xF25b303C52844D8076Dcb96b6d7225e48C047661);
        // _allUsersAddress[179] = 0xF25b303C52844D8076Dcb96b6d7225e48C047661  ; 
        // _users[_allUsersAddress[179]] = Node(  1,    0,        0,   20,     1,   1,
        //     0x4473d67e673D751fE9D982eA8e9888B3b28ef830  ,
        //     0x506EcE5ccC15Cf9E5C2410D05a133C24140C1e63 ,
        //     address(0));
        // _allUsersAddress[180] =  0x506EcE5ccC15Cf9E5C2410D05a133C24140C1e63 ; 
        // _users[_allUsersAddress[180]] = Node( 0,    0,       0,    21,     0,   0,
        //     0xF25b303C52844D8076Dcb96b6d7225e48C047661  ,
        //     address(0),       address(0));
        // _allUsersAddress[181] = 0xF4D1bBedE30921fb640f3d25ECFee7c6A382Dd5E ; 
        // _users[_allUsersAddress[181]] = Node(   8,    0,       0,    19,     1,   1,
        //     0x631917c03e75c4c0581fc753C7720f0BcdB2fFbd  ,
        //     0x7Ba5D1499a5B9dD087f2cB29E337109F1b2e9a46 ,
        //     address(0));
        // _allUsersAddress[182] = 0x7Ba5D1499a5B9dD087f2cB29E337109F1b2e9a46 ; 
        // _users[_allUsersAddress[182]] = Node(   7,    0,        0,    20,     1,   0,
        //     0xF4D1bBedE30921fb640f3d25ECFee7c6A382Dd5E  ,
        //     0x12C09e50EaED25c04B1b5aF46Ea94308110A145e ,
        //     address(0));
        // _allUsersAddress[183] = 0x12C09e50EaED25c04B1b5aF46Ea94308110A145e ; 
        // _users[_allUsersAddress[183]] = Node( 6,    0,        0,    21,     1,   0,
        //     0x7Ba5D1499a5B9dD087f2cB29E337109F1b2e9a46 ,
        //     0xC0c99aE595C14D9D26cB650B70118ade1e1496D7 ,
        //     address(0));
        // _allUsersAddress[184] = 0xC0c99aE595C14D9D26cB650B70118ade1e1496D7 ; 
        // _users[_allUsersAddress[184]] = Node( 0,  3,       0,   22,    2,   0,
        //      0x12C09e50EaED25c04B1b5aF46Ea94308110A145e ,
        //     0xD31fBA568B548cB376E25B046092b7adD4FF49f6,
        //     0x042D9e14f066053Ed1F9778Afcb94afbEEf8D4d7);
        // _allUsersAddress[185] = 0xD31fBA568B548cB376E25B046092b7adD4FF49f6 ;   
        // _users[_allUsersAddress[185]] = Node( 0,   0,        0,    23,     0,   0,
        //     0xC0c99aE595C14D9D26cB650B70118ade1e1496D7  ,
        //     address(0),        address(0));
        // _allUsersAddress[186] = 0x042D9e14f066053Ed1F9778Afcb94afbEEf8D4d7 ;  
        // _users[_allUsersAddress[186]] = Node( 0,    1,        0,   23 ,    2,   1,
        //     0xC0c99aE595C14D9D26cB650B70118ade1e1496D7 ,
        //     0xC18D046A843807E34944734d3b65F8E6c733627D ,
        //      0xec35E2bdc0E6502F2EDF36C16e10224bd56eA1f4);
        // _allUsersAddress[187] = 0xC18D046A843807E34944734d3b65F8E6c733627D ;  
        // _users[_allUsersAddress[187]] = Node( 0,   0,        0,    24,     0,   0,
        //     0x042D9e14f066053Ed1F9778Afcb94afbEEf8D4d7 ,
        //     address(0),      address(0));
        // _allUsersAddress[188] =  0xec35E2bdc0E6502F2EDF36C16e10224bd56eA1f4 ;   
        // _users[_allUsersAddress[188]] = Node( 1,    0,        0,    24,     1,   1,
        //     0x042D9e14f066053Ed1F9778Afcb94afbEEf8D4d7 ,
        //     0xD9b403f28B1c7F46F90a40C056266106Fd3DEcfD ,
        //     address(0));
        // _allUsersAddress[189] = 0xD9b403f28B1c7F46F90a40C056266106Fd3DEcfD ;  
        // _users[_allUsersAddress[189]] = Node( 0,    0,     0,    25,     0,   0,
        //      0xec35E2bdc0E6502F2EDF36C16e10224bd56eA1f4 ,
        //     address(0),   address(0));
        // _allUsersAddress[190] = 0xD0E8f9B3D55ee79Bb32Ab98870bC20Dc94d24a72 ;  
        // _users[_allUsersAddress[190]] = Node( 11,    0,       0,   20 ,     2,   0,
        //     0x4473d67e673D751fE9D982eA8e9888B3b28ef830 ,
        //     0x963baFAe69c1686124B3c4D6db85e861Bf3d5fF7 ,
        //     0x4864a3574081C5EE06d103053491afa87bB38376);
        // _allUsersAddress[191] = 0x963baFAe69c1686124B3c4D6db85e861Bf3d5fF7 ;  
        // _users[_allUsersAddress[191]] = Node( 11,  0,       0,    21,    1,   0,
        //     0xD0E8f9B3D55ee79Bb32Ab98870bC20Dc94d24a72 ,
        //     0x1478303FB705d0797caF843d76E6ceE1A8fe9c67 ,
        //     address(0));
        // _allUsersAddress[192] = 0x4864a3574081C5EE06d103053491afa87bB38376 ;  
        // _users[_allUsersAddress[192]] = Node(  0,    0,       0,    21,    0,  1,
        //     0xD0E8f9B3D55ee79Bb32Ab98870bC20Dc94d24a72  ,
        //     address(0),    address(0));
        // _allUsersAddress[193] = 0x1478303FB705d0797caF843d76E6ceE1A8fe9c67 ;  
        // _users[_allUsersAddress[193]] = Node( 0,    6,     0,    22,   2,   0,
        //     0x963baFAe69c1686124B3c4D6db85e861Bf3d5fF7  ,
        //     0xCc61A69a23274e421E19E0eD49cA6b6fd120aaa9 ,
        //     0x2ba33a890ebA5157d34489A2458146Cd2C9B894C);
        // _allUsersAddress[194] = 0xCc61A69a23274e421E19E0eD49cA6b6fd120aaa9 ;   
        // _users[_allUsersAddress[194]] = Node( 1,    0,       0,    23,     1,   0,
        //     0x1478303FB705d0797caF843d76E6ceE1A8fe9c67   ,
        //     0xA7e53b39fC3F55ACcf8077CEcBFcf6c0CAeB4f5B ,
        //     address(0));
        // _allUsersAddress[195] = 0xA7e53b39fC3F55ACcf8077CEcBFcf6c0CAeB4f5B ; 
        // _users[_allUsersAddress[195]] = Node(0,   0,      0,   24,     0,   0,
        //     0xCc61A69a23274e421E19E0eD49cA6b6fd120aaa9  ,
        //     address(0),   address(0));
        // _allUsersAddress[196] = 0x2ba33a890ebA5157d34489A2458146Cd2C9B894C ; 
        // _users[_allUsersAddress[196]] = Node( 0,    6,       0,    23,     2,   1,
        //     0xCc61A69a23274e421E19E0eD49cA6b6fd120aaa9  ,
        //     0x4EbFC534b662D3E4F38E41943A05acd957a9De02 ,
        //     0xD72953F851DdE65da031DBF1e863fb66cefC65A4);
        // _allUsersAddress[197] = 0x4EbFC534b662D3E4F38E41943A05acd957a9De02 ;  
        // _users[_allUsersAddress[197]] = Node( 0,   0,       0,    24,     0,   0,
        //     0x2ba33a890ebA5157d34489A2458146Cd2C9B894C  ,
        //     address(0),   address(0));
        // _allUsersAddress[198] = 0xD72953F851DdE65da031DBF1e863fb66cefC65A4 ;  
        // _users[_allUsersAddress[198]] = Node( 0,    1,          0,   24,     2,   1,
        //     0x2ba33a890ebA5157d34489A2458146Cd2C9B894C  ,
        //    0xeFefef66a97456459d988478B4e34B2178F7F4C9 ,
        //     0xEbA6A85796c7d23108423a26645DC03f2919D4be);
        // _allUsersAddress[199] = 0xeFefef66a97456459d988478B4e34B2178F7F4C9 ;  
        // _users[_allUsersAddress[199]] = Node(  1,    0,     0,    25,     1,   0,
        //     0xD72953F851DdE65da031DBF1e863fb66cefC65A4  ,
        //     0x6C8c4001C7b88457b100C54B0850Eb0D7B028deE,
        //     address(0));
    //     _allUsersAddress[200] = 0x6C8c4001C7b88457b100C54B0850Eb0D7B028deE ;  
    //     _users[_allUsersAddress[200]] = Node( 0,   0,       0,    26,     0,   0,
    //          0xeFefef66a97456459d988478B4e34B2178F7F4C9 ,
    //         address(0),      address(0));
    //     _allUsersAddress[201] = 0xEbA6A85796c7d23108423a26645DC03f2919D4be ;  
    //     _users[_allUsersAddress[201]] = Node( 2,    0,       0,    25,     1,   1,
    //          0xD72953F851DdE65da031DBF1e863fb66cefC65A4 ,
    //         0x62B7B2A252fd9ee3A2ee70919DCC19FD31101570 ,
    //         address(0));
    //     _allUsersAddress[202] = 0x62B7B2A252fd9ee3A2ee70919DCC19FD31101570 ;   
    //     _users[_allUsersAddress[202]] = Node( 1,    0,       0,    26,     1,   0,
    //         0xEbA6A85796c7d23108423a26645DC03f2919D4be  ,
    //         0x0e1491135Dd764Afe5C92326D00F2887511e00B5,
    //         address(0));
    //     _allUsersAddress[203] = 0x0e1491135Dd764Afe5C92326D00F2887511e00B5 ;  
    //     _users[_allUsersAddress[203]] = Node( 0,    0,        0,    27,     0,   0,
    //         0x62B7B2A252fd9ee3A2ee70919DCC19FD31101570  ,
    //         address(0),    address(0));
    //     _allUsersAddress[204] = 0x8E1DE9e68884647aD599D3f9dFa98D23E4707803 ;  
    //     _users[_allUsersAddress[204]] = Node(  16,   0,       0,    18,     1,   1,
    //          0x1464154ED8e4503Cd44b0B61eB92e30a2ABE1844 ,
    //         0xB3E96c93E36a99C451a0047D70298A52fF5Fe473,
    //         address(0));
    //     _allUsersAddress[205] = 0xB3E96c93E36a99C451a0047D70298A52fF5Fe473 ; 
    //     _users[_allUsersAddress[205]] = Node( 0,    9,       0,    19,     2,   0,
    //         0x8E1DE9e68884647aD599D3f9dFa98D23E4707803  ,
    //         0xf6e419a40d681753bc912e5894C90820A989123E ,
    //         0xF8747bc8B4615A4f72D2c18D0c7DF0aE20f889B9);
    //     _allUsersAddress[206] = 0xf6e419a40d681753bc912e5894C90820A989123E ; 
    //     _users[_allUsersAddress[206]] = Node( 2,    0,        0,    20,     1,   0,
    //         0xB3E96c93E36a99C451a0047D70298A52fF5Fe473  ,
    //         0x38E8C7b901be6ECCcb90088Cde59afc3198C90d2,
    //         address(0));
    //     _allUsersAddress[207] = 0x38E8C7b901be6ECCcb90088Cde59afc3198C90d2 ; 
    //     _users[_allUsersAddress[207]] = Node( 1,    0,       0,    21,     1,   0,
    //         0xf6e419a40d681753bc912e5894C90820A989123E  ,
    //         0xddc2BfEA720e9964F37c7697bB740c46C2322404 ,
    //         address(0));
    //     _allUsersAddress[208] = 0xddc2BfEA720e9964F37c7697bB740c46C2322404 ;  
    //     _users[_allUsersAddress[208]] = Node( 0,    0,           0,    22,     0,   0,
    //         0x38E8C7b901be6ECCcb90088Cde59afc3198C90d2  ,
    //         address(0),     address(0));
    //     _allUsersAddress[209] = 0xF8747bc8B4615A4f72D2c18D0c7DF0aE20f889B9 ;   
    //     _users[_allUsersAddress[209]] = Node(   11,    0,         0,    20,     1,   1,
    //          0xB3E96c93E36a99C451a0047D70298A52fF5Fe473 ,
    //         0x453F9022679253e36310d6a07cD0AB34D4cB08e1,
    //         address(0));
    //     _allUsersAddress[210] = 0x453F9022679253e36310d6a07cD0AB34D4cB08e1 ;   
    //     _users[_allUsersAddress[210]] = Node( 0,    2,       0,    21,     2,   0,
    //         0xF8747bc8B4615A4f72D2c18D0c7DF0aE20f889B9 ,
    //         0xab35d748cE43E010104D7112A52392dE2c07FEf1 ,
    //         0x599fea5f2a8EBFC329c184DB6E8DE6d17739D91a);
    //     _allUsersAddress[211] = 0xab35d748cE43E010104D7112A52392dE2c07FEf1 ; 
    //     _users[_allUsersAddress[211]] = Node(  3,    0,     0,    22,     1,   0,
    //         0x453F9022679253e36310d6a07cD0AB34D4cB08e1  ,
    //         0xdCA962C3aa9Ed203ECcA697CE59d47049476a94A ,
    //         address(0));
    //     _allUsersAddress[212] = 0xdCA962C3aa9Ed203ECcA697CE59d47049476a94A ; 
    //     _users[_allUsersAddress[212]] = Node(  2,    0,     0,    23,     1,   0,
    //         0xab35d748cE43E010104D7112A52392dE2c07FEf1  ,
    //         0xE3d2c487BeBdD4A0a347133B6c57dbb4929D15c4 ,
    //         address(0));
    //     _allUsersAddress[213] = 0xE3d2c487BeBdD4A0a347133B6c57dbb4929D15c4 ; 
    //     _users[_allUsersAddress[213]] = Node(  1,    0,     0,    24,     1,   0,
    //         0xdCA962C3aa9Ed203ECcA697CE59d47049476a94A  ,
    //         0x495A906d412c4D216314DB53b66e9B571c0Fa671 ,
    //         address(0));
    //     _allUsersAddress[214] = 0x495A906d412c4D216314DB53b66e9B571c0Fa671 ; 
    //     _users[_allUsersAddress[214]] = Node(  0,    0,      0,   25,     0,   0,
    //          0xE3d2c487BeBdD4A0a347133B6c57dbb4929D15c4 ,
    //         address(0),    address(0));
    //     _allUsersAddress[215] = 0x599fea5f2a8EBFC329c184DB6E8DE6d17739D91a ; 
    //     _users[_allUsersAddress[215]] = Node(  0,   3,        0,    22,     2,   1,
    //         0x453F9022679253e36310d6a07cD0AB34D4cB08e1 ,
    //         0xCBaeB58BBcf8271D19156F75bC8753778A845d34 ,
    //         0xCBaeB58BBcf8271D19156F75bC8753778A845d34);
    //     _allUsersAddress[216] = 0xCBaeB58BBcf8271D19156F75bC8753778A845d34 ; 
    //     _users[_allUsersAddress[216]] = Node(  0,    0,      0,    23,     0,   0,
    //         0x599fea5f2a8EBFC329c184DB6E8DE6d17739D91a  ,
    //         address(0),    address(0));
    //     _allUsersAddress[217] = 0xCBaeB58BBcf8271D19156F75bC8753778A845d34 ;   
    //     _users[_allUsersAddress[217]] = Node(  3,    0,     0,   23 ,     1,   1,
    //         0x599fea5f2a8EBFC329c184DB6E8DE6d17739D91a  ,
    //         0xEefd9807bd2c8Cb853C7F5014141f618154E2005 ,
    //         address(0));
    //     _allUsersAddress[218] = 0xEefd9807bd2c8Cb853C7F5014141f618154E2005 ;
    //     _users[_allUsersAddress[218]] = Node(  0,    0,        0,    24,     2,   0,
    //         0xCBaeB58BBcf8271D19156F75bC8753778A845d34 ,
    //         0x4177e472be6391682d3d562937874c64D9870500 ,
    //         0xd639075B3E429C555708eCa1a05CfEDd3d24458c);
    //     _allUsersAddress[219] = 0x4177e472be6391682d3d562937874c64D9870500 ; 
    //     _users[_allUsersAddress[219]] = Node( 0,    0,     0,    25,     0,   0,
    //         0xEefd9807bd2c8Cb853C7F5014141f618154E2005  ,
    //         address(0),    address(0));
    //     _allUsersAddress[220] = 0xd639075B3E429C555708eCa1a05CfEDd3d24458c ; 
    //     _users[_allUsersAddress[220]] = Node(  0,    0,      0,    25,     0,   1,
    //         0xEefd9807bd2c8Cb853C7F5014141f618154E2005  ,
    //         address(0), address(0));
    //     _allUsersAddress[221] = 0x6d9c6B9B130DABe61E2D993714A5B9Ba90075C09  ;  
    //     _users[_allUsersAddress[221]] = Node(  17,  0,   0,  17,  2,  0,
    //         0x57fe19475Ce1f70516C3D981d0fD30d1ee225c63 ,
    //         0x57C9feb3Fa05F57fa498fD0Ac6B2462Db57Ae94D ,
    //         0x20720969B9C07694EabD9549d3E2B961E5b1112F);
    //     _allUsersAddress[222] =  0x57C9feb3Fa05F57fa498fD0Ac6B2462Db57Ae94D ;  
    //     _users[_allUsersAddress[222]] = Node( 17,   0,    0,   18,   1,   0,
    //         0x6d9c6B9B130DABe61E2D993714A5B9Ba90075C09 ,
    //         0xb075B88995Be139A9E915E35C66385a844c8DCA4 ,
    //         address(0));
    //     _allUsersAddress[223] =  0x20720969B9C07694EabD9549d3E2B961E5b1112F ;  
    //     _users[_allUsersAddress[223]] = Node(   0,   0,    0,   18,   0,    1,
    //         0x6d9c6B9B130DABe61E2D993714A5B9Ba90075C09  ,
    //         address(0),    address(0));
    //     _allUsersAddress[224] =  0xb075B88995Be139A9E915E35C66385a844c8DCA4 ; 
    //     _users[_allUsersAddress[224]] = Node( 12,    0,     0,   19,    2,   0,
    //         0x57C9feb3Fa05F57fa498fD0Ac6B2462Db57Ae94D  ,
    //         0x0D385c4Fce862fb373dad667457468bea5823F13,
    //         0x17EEbC006b0E4187617e8a54bA4ab50C8ba08e56);
    //     _allUsersAddress[225] =  0x0D385c4Fce862fb373dad667457468bea5823F13 ;  
    //     _users[_allUsersAddress[225]] = Node(  13,    0,      0,    20,    1,    0,
    //         0xb075B88995Be139A9E915E35C66385a844c8DCA4 ,
    //         address(0),       address(0));
    //     _allUsersAddress[226] =  0x17EEbC006b0E4187617e8a54bA4ab50C8ba08e56 ;  
    //     _users[_allUsersAddress[226]] = Node( 1,   0,    0,    20,    1,    1,
    //         0xb075B88995Be139A9E915E35C66385a844c8DCA4 ,
    //         0x13C7B5125F4566891AA3b97a4FCA33bD3272842D ,
    //         address(0));
    //     _allUsersAddress[227] =  0x13C7B5125F4566891AA3b97a4FCA33bD3272842D ;  
    //     _users[_allUsersAddress[227]] = Node( 0,  0,   0,   21,    0,    0,
    //         0x17EEbC006b0E4187617e8a54bA4ab50C8ba08e56 ,
    //         address(0),      address(0));
    //     _allUsersAddress[228] = 0x474acFBC05097e5A588Ae7E1032B688fec119B48  ; 
    //     _users[_allUsersAddress[228]] = Node( 10,  0,    0,    21,    2,    0,
    //         0x0D385c4Fce862fb373dad667457468bea5823F13 ,
    //         0x501C79514af459984bAe37668190758096C7D094 ,
    //         0x8E763d785df0adE6fE9c50F2574e111018a04cb5);
    //     _allUsersAddress[229] =  0x501C79514af459984bAe37668190758096C7D094 ;  
    //     _users[_allUsersAddress[229]] = Node( 10,   0,     0,  22, 1,  0,
    //         0x474acFBC05097e5A588Ae7E1032B688fec119B48  ,
    //         0x25a99eDF10b1112708e6AC3bbBaBe2C46b7F9E80,
    //         address(0));
    //     _allUsersAddress[230] =  0x8E763d785df0adE6fE9c50F2574e111018a04cb5 ;  
    //     _users[_allUsersAddress[230]] = Node( 0,   0,      0,    22,   0,  1,
    //         0x474acFBC05097e5A588Ae7E1032B688fec119B48  ,
    //         address(0),       address(0) );
    //     _allUsersAddress[231] =  0x25a99eDF10b1112708e6AC3bbBaBe2C46b7F9E80  ; 
    //     _users[_allUsersAddress[231]] = Node( 9,  0,     0,   23,   1,    0,
    //         0x501C79514af459984bAe37668190758096C7D094  ,
    //         0x6ab23a6b5F909d36A48289C0cE4857BfE0B6De96 ,
    //         address(0) );
    //     _allUsersAddress[232] = 0x6ab23a6b5F909d36A48289C0cE4857BfE0B6De96  ;  
    //     _users[_allUsersAddress[232]] = Node( 6,   0,      0,    24,    2,    0,
    //         0x25a99eDF10b1112708e6AC3bbBaBe2C46b7F9E80 ,
    //         0x1C5B082D57bb4ECA1d6d52D2b0364D8D93849191 ,
    //         0x6E77C4527D00DE379581D03649268ce29BF8d786 );
    //     _allUsersAddress[233] =  0x6E77C4527D00DE379581D03649268ce29BF8d786 ; 
    //     _users[_allUsersAddress[233]] = Node(  0,  0,      0,   25,    0,    1,
    //         0x6ab23a6b5F909d36A48289C0cE4857BfE0B6De96  ,
    //         address(0),      address(0) );
    //     _allUsersAddress[234] =  0x1C5B082D57bb4ECA1d6d52D2b0364D8D93849191 ;  
    //     _users[_allUsersAddress[234]] = Node( 6,   0,    0,   25,   1,   0,
    //          0x6ab23a6b5F909d36A48289C0cE4857BfE0B6De96 ,
    //         0xe7ff3aFD4abC4971F25Fd9cC4d5a1B5A5Ad2b405,
    //         address(0));
    //     _allUsersAddress[235] = 0xe7ff3aFD4abC4971F25Fd9cC4d5a1B5A5Ad2b405  ;  
    //     _users[_allUsersAddress[235]] = Node(  3,  0,   0,  26,  2,   0,
    //         0x1C5B082D57bb4ECA1d6d52D2b0364D8D93849191  ,
    //         0x1fA3fc334707e0AFf0d0a1Bc81F0A92328219445 ,
    //         0x210d16845D77F3b488859A9f7B25D279b9d7dc6D );
    //     _allUsersAddress[236] =  0x210d16845D77F3b488859A9f7B25D279b9d7dc6D ; 
    //     _users[_allUsersAddress[236]] = Node(  0,  0,    0,  27,  0,  1,
    //         0xe7ff3aFD4abC4971F25Fd9cC4d5a1B5A5Ad2b405  ,
    //         address(0),      address(0) );
    //     _allUsersAddress[237] = 0x1fA3fc334707e0AFf0d0a1Bc81F0A92328219445  ; 
    //     _users[_allUsersAddress[237]] = Node(  1,  0,  0,   27,   2,    0,
    //         0xe7ff3aFD4abC4971F25Fd9cC4d5a1B5A5Ad2b405  ,
    //         0x4e1680b6C622092ba27743b099Ab9Aefa23d4b0f,
    //         0x226F3DF5DaD7c3D02530664956F5293306e7038D );
    //     _allUsersAddress[238] = 0x0A2389f1B16E0D191C94F3D19Fce980c00A56800  ;    
    //     _users[_allUsersAddress[238]] = Node( 0,  230,    0,    2,    0,   1,
    //        0xf77aF59DFF41226E2c71eE3ea947227D296985d6 ,
    //        address(0) ,
    //        address(0));

    }
}