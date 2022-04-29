/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;


contract Ballot {

    uint stayOnBinance = 0;
    uint changeToMoonbeam = 0;
    address ballotOfficialAddress = 0x9A0e3A6Dfc8E3C9Ba53d59C120898883d0Cee732;
    State state;

    struct Voter {
        bool hasVoted;
        bool exists;
        bool choice;
    }

    mapping(address => Voter) public voters;

    enum State { Voting, Ended }

    modifier inState(State _state) {
        require(state == _state);
        _;

    }

    constructor() {
        voters[0x511D365E3e0D01F29E092706664c6559A8328123] = Voter(false, true, false); //T voter3 
        voters[0x9A0e3A6Dfc8E3C9Ba53d59C120898883d0Cee732] = Voter(false, true, false); //T voter4 
        voters[0x2B591447e758B02a291a91deAA08341f1b6d4E92] = Voter(false, true, false); //T voter5 
        voters[0x3995A4372e0e2F217786f0c3f125891a32DEe889] = Voter(false, true, false); //T voter6 
        voters[0xba472F1b9473ed6D7bD62993992bD215B77b9380] = Voter(false, true, false); //T voter7
        voters[0xd760dE41EfD1DC2EbfF26C55419181B4Ff8F2d64] = Voter(false, true, false); //T voter8
        voters[0x546B7CfdD4ffDbD736790B0eeA1c991001A4f5A9] = Voter(false, true, false); //T voter9
        voters[0xf1Ab4639602D7261e69EE07bEB8861dE9cA96AB2] = Voter(false, true, false); //T voter10


        voters[0x7E1432897cb4674D3D8653B017c4299C8d11fA06] = Voter(false, true, false); //0
        voters[0x3697BBFe9c6083C1eBC2d9B01205B1Ec85C20f57] = Voter(false, true, false); //1
        voters[0x0574DF252FCc3B1AFa344dcf5B359D4280BbE5f9] = Voter(false, true, false); //2
        voters[0x6E2fe8d024218A2261AD3bC020C8cb8DF224F6E2] = Voter(false, true, false); //3
        voters[0x7D0dc82A66752F79fe875a2317EF3761bD8d2633] = Voter(false, true, false); //4
        voters[0xF5492e21132E4a81CB1823E43e747203cC3eAc1a] = Voter(false, true, false); //5
        voters[0xDc511186CA93f6fdb9B147d9ed80105a9E52d30F] = Voter(false, true, false); //6
        voters[0xD76a89E2AD3516eE02b4ACF8890FBaF777646F2c] = Voter(false, true, false); //7
        voters[0x595df290F1e5D9db6e81d3D7A51d2B173CA7f781] = Voter(false, true, false); //8
        voters[0x78aB3c8248b08c0293FBb14189dCb4dE19F78051] = Voter(false, true, false); //9
        voters[0x106fe22F2a3b506F507da64b793d694A627ef05f] = Voter(false, true, false); //10
        voters[0xCe0D246b3889E830BE51683a08e7CEa1439fA1D4] = Voter(false, true, false); //11
        voters[0x3AC7d2D91DDcD37695469e3D6b729e181005F802] = Voter(false, true, false); //12
        voters[0xd198E93Ec14498210a62bdff359f9D7AD48B92Cf] = Voter(false, true, false); //13
        voters[0x09CA6D888192F6713C6EEDF87Ef01226cb7C59e1] = Voter(false, true, false); //14
        voters[0xAC234afC957420e240d6Ad53eDbAC6FD60cEbC61] = Voter(false, true, false); //15
        voters[0x3f3821A799DADFAB4AcCD08ff040dcfBFd081EE1] = Voter(false, true, false); //16
        voters[0x4f1C0B54aE094909efA201a7C71b10239c9c4cc2] = Voter(false, true, false); //17
        voters[0x6d68dd66Cd99b2E080F1428741429EB15463E6fd] = Voter(false, true, false); //18
        voters[0x783eFB0aAe310E7B2d868Ad6a5e6109eE8Ae55cD] = Voter(false, true, false); //19
        voters[0x7f7fc64f8E66841861Bc7A5115f57a40B979F831] = Voter(false, true, false); //20
        voters[0xa51DFC83765daae9Cd734A7a76741823104d2BaD] = Voter(false, true, false); //21
        voters[0xB139D98f7Ea96d56cde4e88d620cc7273Cb6E062] = Voter(false, true, false); //22
        voters[0xc966392DC62da2C60C484b46CB97C36330565Bf1] = Voter(false, true, false); //23
        voters[0xcd9B991Ffd4a15B64B9E9f528EBf0D4262E0f2C5] = Voter(false, true, false); //24
        voters[0x05C731E79AC5b04baD3bC273632a5aE19AcF5A9B] = Voter(false, true, false); //25
        voters[0x1c01b559b4e8AB181339c8F66ffEFEc703864a37] = Voter(false, true, false); //26
        voters[0x233715dCa4EC15A17a67Acac3DdE7A32e38395F6] = Voter(false, true, false); //27
        voters[0x2Cc4f69A64b0368cc8253DEA3d50691ecCD61781] = Voter(false, true, false); //28
        voters[0x2E4E05902fe066128abC395E6D520080e0b3a202] = Voter(false, true, false); //29
        voters[0x825A4661dCE0C6Fa8993EEd2a0Ca90f49a43e2E2] = Voter(false, true, false); //30
        voters[0x881e00258e3faa322d242E038f0D47E996fA126e] = Voter(false, true, false); //31
        voters[0x8a1cB58831fcf000133616f35b213Af952cC9F3b] = Voter(false, true, false); //32
        voters[0xB4C2C5739c571C57F56ADc8D8cfFa8F4E7f06A88] = Voter(false, true, false); //33
        voters[0xd4b430CA940901662212729D0e07bE3F6394FA56] = Voter(false, true, false); //34
        voters[0xDa7172aDcaFC9e3Fdd3CE0999637C4A90044BBBA] = Voter(false, true, false); //35
        voters[0xF12F2A5565dF147F0c4C29c4593880A9fe24Fb57] = Voter(false, true, false); //36

        voters[0xdB0B0F4011016267a174121590DeEACAEe1F35AF] = Voter(false, true, false); //1
        voters[0x50177EE10fb984305a606E5E8dBd0be21197903A] = Voter(false, true, false); //2
        voters[0x71E37f5F98fb19667B7138e716D18F6790726e46] = Voter(false, true, false); //3
        voters[0x832E5EF6f95A3333e911F3d5D7E905788D16EDb1] = Voter(false, true, false); //4
        voters[0x7203c2638dBE6588c7e6998E26683A03A9C42867] = Voter(false, true, false); //5
        voters[0x34e11020a9cAb52D083f08c4e7A383a76Bd384b0] = Voter(false, true, false); //6
        voters[0x49783fa49CE3d9DFABE575C39e062D7F72cC4873] = Voter(false, true, false); //7
        voters[0x6aF3f058b3A3E25c828aa65Da301C6D6DACA2cfA] = Voter(false, true, false); //8
        voters[0xBf5a1aD8698e92029D6a8d1eded11e1B27186757] = Voter(false, true, false); //9
        voters[0xCCE4cABb41732bDd24cCd45b5C4E5b67fB808505] = Voter(false, true, false); //10
        voters[0xd94538a88D2a3DC3A6DD096F6f6553E22557CE92] = Voter(false, true, false); //11
        voters[0xefA1E0DD42D1c66e782336489E411C23CDB7D59a] = Voter(false, true, false); //12



    }



    function voteForBinance() public {
        require(voters[msg.sender].exists == true, "Only Hodlbag Token & NFT holders can vote.");
        require(voters[msg.sender].hasVoted == false, "This address already voted.");
        voters[msg.sender].hasVoted = true;
        stayOnBinance = stayOnBinance +1;
        
        

    }

    function voteForMoonbeam() public {
        require(voters[msg.sender].exists == true, "Only Hodlbag Token & NFT holders can vote.");
        require(voters[msg.sender].hasVoted == false, "This address already voted.");
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].choice = true;
        changeToMoonbeam = changeToMoonbeam +1;
        

    }

    function getVoteCount() public view returns (uint _binance, uint _moonbeam) {
        return (stayOnBinance, changeToMoonbeam);
    }


    function endVote() inState(State.Voting) public {
        require(msg.sender == ballotOfficialAddress, "Only ballotOfficialAddress can end the voting!");
        state = State.Ended;
    }

    function determineWinner() public view returns (string memory){
        if (stayOnBinance > changeToMoonbeam) {
            return "stayOnBinance";
            }
         else if (changeToMoonbeam > stayOnBinance) {
            return "changeToMoonbeam";
            }
            else return "manual tiebreaker required";
        
    }
}