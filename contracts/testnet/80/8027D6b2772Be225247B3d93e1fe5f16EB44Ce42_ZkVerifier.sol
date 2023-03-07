// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.18;

struct BeaconBlockHeader {
    uint64 slot;
    uint64 proposerIndex;
    bytes32 parentRoot;
    bytes32 stateRoot;
    bytes32 bodyRoot;
}

struct LightClientUpdate {
    // Header attested to by the sync committee
    BeaconBlockHeader attestedHeader;
    // Finalized header corresponding to `attested_header.state_root`
    BeaconBlockHeader finalizedHeader;
    bytes32[] finalityBranch;
    bytes32 finalizedExecutionStateRoot;
    bytes32[] finalizedExecutionStateRootBranch;
    bytes32 optimisticExecutionStateRoot;
    bytes32[] optimisticExecutionStateRootBranch;
    bytes32 nextSyncCommitteeRoot;
    bytes32[] nextSyncCommitteeBranch;
    bytes32 nextSyncCommitteePoseidonRoot;
    Proof nextSyncCommitteeRootMappingProof;
    // Sync committee aggregate signature participation & zk proof
    SyncAggregate syncAggregate;
    // Slot at which the aggregate signature was created (untrusted)
    uint64 signatureSlot;
}

struct SyncAggregate {
    uint64 participation;
    bytes32 poseidonRoot;
    Proof proof;
}

struct Proof {
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
}

// SPDX-License-Identifier: AML
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

// 2019 OKIMS

pragma solidity ^0.8.0;

import "./Pairing.sol";
import "./Constants.sol";
import "./Common.sol";

contract BlsSigVerifier {
    using Pairing for *;

    function verifyingKey() private pure returns (Common.VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(
            uint256(16911711186432120094406167952308296783564962360374508997397923087832927523452),
            uint256(16958111314286347510013353583140722938285661155928524007535396770300838300222)
        );
        vk.beta2 = Pairing.G2Point(
            [
                uint256(21454251991495730986643805295888501473970840601709532226318584490387104913729),
                uint256(2917062111691328343612382672934083503565040996308880671892843648583219631215)
            ],
            [
                uint256(4419476390750848540709862654466988414739774496710365131232573979016190662595),
                uint256(13653004255625935239293213309837544816691204037906162416550104024082724917315)
            ]
        );
        vk.gamma2 = Pairing.G2Point(
            [
                uint256(15219969119829449138309592099329963783251841001409110697736829604991747979575),
                uint256(17225388966463464940867935119463804194147922955543503595549710044505610844770)
            ],
            [
                uint256(11563468903980449231408312646957393861328856628694432594786520425329872358600),
                uint256(706820252680189564096877097428266348420040781303176388943186460279432102461)
            ]
        );
        vk.delta2 = Pairing.G2Point(
            [
                uint256(12083865704820074402462203960356089131476391298814939806867269987290753762105),
                uint256(15645577226473362415126385246308031281847607817067507717642865677524561312981)
            ],
            [
                uint256(16742870416334534904854353803269526218812791193653910121429357546811002238433),
                uint256(20267684942693645290380344212030129170448709320791114897364490210911267895477)
            ]
        );
    }

    /*
     * @returns Whether the proof is valid given the hardcoded verifying key
     *          above and the public inputs
     */
    function verifyBlsSigProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[34] memory input
    ) public view returns (bool r) {
        Common.Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);

        // Make sure that proof.A, B, and C are each less than the prime q
        require(proof.A.X < PRIME_Q, "verifier-aX-gte-prime-q");
        require(proof.A.Y < PRIME_Q, "verifier-aY-gte-prime-q");

        require(proof.B.X[0] < PRIME_Q, "verifier-bX0-gte-prime-q");
        require(proof.B.Y[0] < PRIME_Q, "verifier-bY0-gte-prime-q");

        require(proof.B.X[1] < PRIME_Q, "verifier-bX1-gte-prime-q");
        require(proof.B.Y[1] < PRIME_Q, "verifier-bY1-gte-prime-q");

        require(proof.C.X < PRIME_Q, "verifier-cX-gte-prime-q");
        require(proof.C.Y < PRIME_Q, "verifier-cY-gte-prime-q");

        // Make sure that every input is less than the snark scalar field
        for (uint256 i = 0; i < input.length; i++) {
            require(input[i] < SNARK_SCALAR_FIELD, "verifier-gte-snark-scalar-field");
        }

        Common.VerifyingKey memory vk = verifyingKey();

        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);

        // Buffer reused for addition p1 + p2 to avoid memory allocations
        // [0:2] -> p1.X, p1.Y ; [2:4] -> p2.X, p2.Y
        uint256[4] memory add_input;

        // Buffer reused for multiplication p1 * s
        // [0:2] -> p1.X, p1.Y ; [3] -> s
        uint256[3] memory mul_input;

        // temporary point to avoid extra allocations in accumulate
        Pairing.G1Point memory q = Pairing.G1Point(0, 0);

        vk_x.X = uint256(12628260047188721507402633572995239077937465141748636929238871325335042470774); // vk.K[0].X
        vk_x.Y = uint256(374789106514435308939729333607432253212262633183545468974313779774353433426); // vk.K[0].Y
        mul_input[0] = uint256(1072443897841180600163641601173187924428220322332724971415613421073836408489); // vk.K[1].X
        mul_input[1] = uint256(4995382102156471285721396039805495655782916921575596803961169040955147774338); // vk.K[1].Y
        mul_input[2] = input[0];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[1] * input[0]
        mul_input[0] = uint256(18252974797331972274985655684137646318400168312221555400987483207654257070281); // vk.K[2].X
        mul_input[1] = uint256(16928944298363927119154420018269922467448269470448218505594531097208963212143); // vk.K[2].Y
        mul_input[2] = input[1];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[2] * input[1]
        mul_input[0] = uint256(4425337740353557481318571761178146926947584186381173192062792213436605318547); // vk.K[3].X
        mul_input[1] = uint256(19427759890194882166272523429160693945920351915924522239532980595367924118162); // vk.K[3].Y
        mul_input[2] = input[2];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[3] * input[2]
        mul_input[0] = uint256(13640284200681140681407549825532425813350148952869847691776951618133176542455); // vk.K[4].X
        mul_input[1] = uint256(7025978338041945589224611251722859194117725028315631703368077901535120766859); // vk.K[4].Y
        mul_input[2] = input[3];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[4] * input[3]
        mul_input[0] = uint256(8658424862592342188795330819844700701096576319545711515893400180524795599678); // vk.K[5].X
        mul_input[1] = uint256(20450945819588409845557804924050204847722887217960737817464330299352250714930); // vk.K[5].Y
        mul_input[2] = input[4];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[5] * input[4]
        mul_input[0] = uint256(21243287687814808516158088857316120483050088403601726296541579441120757352220); // vk.K[6].X
        mul_input[1] = uint256(21438047297038843517334679174245728209162192884601612662176914812523868435468); // vk.K[6].Y
        mul_input[2] = input[5];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[6] * input[5]
        mul_input[0] = uint256(2433387358401656449613957154303466738602656950437276570994754300616567288439); // vk.K[7].X
        mul_input[1] = uint256(20455243795479100491327901749169333756530917770430254010608375582199416302174); // vk.K[7].Y
        mul_input[2] = input[6];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[7] * input[6]
        mul_input[0] = uint256(18960645297220457104332100207500703973596448854206260187438282349034498265411); // vk.K[8].X
        mul_input[1] = uint256(19139838243136029476040879738841229097357599751672713342079755268606834466697); // vk.K[8].Y
        mul_input[2] = input[7];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[8] * input[7]
        mul_input[0] = uint256(11033798223370376678670638812721448076487073146582619347863987920254417862252); // vk.K[9].X
        mul_input[1] = uint256(287051572523895364214048767124627333425065007705625697958480971988128634144); // vk.K[9].Y
        mul_input[2] = input[8];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[9] * input[8]
        mul_input[0] = uint256(10710156256797398670222936384446577143639871295394864506398796536162751962909); // vk.K[10].X
        mul_input[1] = uint256(19273903692155197084974834255476390307359855002486716922159792395039118848197); // vk.K[10].Y
        mul_input[2] = input[9];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[10] * input[9]
        mul_input[0] = uint256(7366801162991697325367172022977550142149821321998574416408094104306208042309); // vk.K[11].X
        mul_input[1] = uint256(9969616086934282601393217502521124400558534738778892720747769640381308947725); // vk.K[11].Y
        mul_input[2] = input[10];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[11] * input[10]
        mul_input[0] = uint256(5536228715011047005866030482072014108057898617107700906148557340654503387588); // vk.K[12].X
        mul_input[1] = uint256(17772299551741198074885905842679715740578221372934859767521271139501187072725); // vk.K[12].Y
        mul_input[2] = input[11];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[12] * input[11]
        mul_input[0] = uint256(16169150204788585645250055797748003762002964717871975367929629952583543401611); // vk.K[13].X
        mul_input[1] = uint256(10788429556912820269669464718359677619307053873486465832301407268967585488354); // vk.K[13].Y
        mul_input[2] = input[12];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[13] * input[12]
        mul_input[0] = uint256(19979642897840262729273269654874785964127219562757810008034999661224396097376); // vk.K[14].X
        mul_input[1] = uint256(10604433911528439841191819424753161527482748012086469029511203310378560756055); // vk.K[14].Y
        mul_input[2] = input[13];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[14] * input[13]
        mul_input[0] = uint256(17927106286797314061872177899945551858599347264206317639453828087058026261446); // vk.K[15].X
        mul_input[1] = uint256(7692060075693548618946812296562858633401575135185673058948093439470566841213); // vk.K[15].Y
        mul_input[2] = input[14];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[15] * input[14]
        mul_input[0] = uint256(395483824020665764559647914552594160823121457095235004954966047407103834894); // vk.K[16].X
        mul_input[1] = uint256(16763381344448438323911162393874859126137568311090205787929020221361878935317); // vk.K[16].Y
        mul_input[2] = input[15];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[16] * input[15]
        mul_input[0] = uint256(253150307890974161841275657883975744252994969466488212347958566248304135331); // vk.K[17].X
        mul_input[1] = uint256(6223359866456963285959976578616089600325345074498740648806060765631001998291); // vk.K[17].Y
        mul_input[2] = input[16];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[17] * input[16]
        mul_input[0] = uint256(2691289317617486181380289288057336036420181220111513555400971865839421081786); // vk.K[18].X
        mul_input[1] = uint256(12913067672747548954794333763004639473665624479453914647540312355193511894442); // vk.K[18].Y
        mul_input[2] = input[17];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[18] * input[17]
        mul_input[0] = uint256(11192982996815173459524496659381739373508844926456670547425589402174263650491); // vk.K[19].X
        mul_input[1] = uint256(20004674939422575968276195043329195805812091570591284070099266965879732549725); // vk.K[19].Y
        mul_input[2] = input[18];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[19] * input[18]
        mul_input[0] = uint256(16775890840806524149552398247516548352368839674540260586584779619524209304445); // vk.K[20].X
        mul_input[1] = uint256(1944206053755229848785756636372446556261209361785746197003985069704991303692); // vk.K[20].Y
        mul_input[2] = input[19];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[20] * input[19]
        mul_input[0] = uint256(10183877289549149912455401534381587912943418816850599592062244334062507171004); // vk.K[21].X
        mul_input[1] = uint256(20392678916251726826728319401809513489429155697589219660726565125376894480418); // vk.K[21].Y
        mul_input[2] = input[20];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[21] * input[20]
        mul_input[0] = uint256(16339897172778517614624922887922370698092792408420035506222165497382802115571); // vk.K[22].X
        mul_input[1] = uint256(12230163396700856129808531969616650849301079294701392193160758325303289393079); // vk.K[22].Y
        mul_input[2] = input[21];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[22] * input[21]
        mul_input[0] = uint256(12848584757986097532484632232050695147066406616017488284126616044852467869163); // vk.K[23].X
        mul_input[1] = uint256(5529292646503014771969209314350873523270294814550049414091542742443591935763); // vk.K[23].Y
        mul_input[2] = input[22];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[23] * input[22]
        mul_input[0] = uint256(18607839562927600650680177834109435418584727893308693982036443225820026193005); // vk.K[24].X
        mul_input[1] = uint256(18355061292307891277826921033187809703510759623103920051220431966922567943728); // vk.K[24].Y
        mul_input[2] = input[23];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[24] * input[23]
        mul_input[0] = uint256(11776122599137721875039861084790890814230852007207309418748915950065528602891); // vk.K[25].X
        mul_input[1] = uint256(13118059925572606040444526359631045121250882673881761566671010925908214248721); // vk.K[25].Y
        mul_input[2] = input[24];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[25] * input[24]
        mul_input[0] = uint256(7958469121513806956473578350245786819269710803041121520986751190795820047711); // vk.K[26].X
        mul_input[1] = uint256(8269260228843793008652484913146033096576995359296227061601512123377617721521); // vk.K[26].Y
        mul_input[2] = input[25];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[26] * input[25]
        mul_input[0] = uint256(3396407134920897667140178688458126868805115573848982021828462514002549756730); // vk.K[27].X
        mul_input[1] = uint256(14156872680357932804005359197816107099972170493184489569701759478167418957188); // vk.K[27].Y
        mul_input[2] = input[26];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[27] * input[26]
        mul_input[0] = uint256(407434957491776994318968471809416187244837302259409458282280394410788993158); // vk.K[28].X
        mul_input[1] = uint256(14913448679081592164038565992375432799937805076336099077165724038770287152854); // vk.K[28].Y
        mul_input[2] = input[27];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[28] * input[27]
        mul_input[0] = uint256(20074465334970524781241769265610964350202992417876614221969280727360185338826); // vk.K[29].X
        mul_input[1] = uint256(11569884215367828378364815419149887451790811627379327502722039492289546990179); // vk.K[29].Y
        mul_input[2] = input[28];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[29] * input[28]
        mul_input[0] = uint256(2245839810470645464304430655076245698876013080906928556640881180365676227353); // vk.K[30].X
        mul_input[1] = uint256(16919211048082078917279398514014956245044155707390493185336231856649349762231); // vk.K[30].Y
        mul_input[2] = input[29];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[30] * input[29]
        mul_input[0] = uint256(3630516425127221582906147290098507422702966115807369239981676054664480517863); // vk.K[31].X
        mul_input[1] = uint256(15461515398272909285282260230950747775889585742468844770963966913453134460926); // vk.K[31].Y
        mul_input[2] = input[30];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[31] * input[30]
        mul_input[0] = uint256(12130462563258209656316724665629072935608513477467453252974467982530426838331); // vk.K[32].X
        mul_input[1] = uint256(7009738295704514125062244256960881550658845480051552904990593672233616340171); // vk.K[32].Y
        mul_input[2] = input[31];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[32] * input[31]
        mul_input[0] = uint256(12227577516196054791997178461830393925748012653108793261373780533544790893502); // vk.K[33].X
        mul_input[1] = uint256(19348977655838679484032219316113257421951361143660915497460119056888916008383); // vk.K[33].Y
        mul_input[2] = input[32];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[33] * input[32]
        mul_input[0] = uint256(2943645815399107884111796483545309610563337607753506951583833118419993893430); // vk.K[34].X
        mul_input[1] = uint256(11078238039340022043432700763827306045295792807330961408021695949310536879453); // vk.K[34].Y
        mul_input[2] = input[33];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[34] * input[33]

        return
            Pairing.pairing(Pairing.negate(proof.A), proof.B, vk.alfa1, vk.beta2, vk_x, vk.gamma2, proof.C, vk.delta2);
    }
}

// SPDX-License-Identifier: AML
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

// 2019 OKIMS

pragma solidity ^0.8.0;

import "./Pairing.sol";
import "./Constants.sol";
import "./Common.sol";

contract CommitteeRootMappingVerifier {
    using Pairing for *;

    function verifyingKey1() private pure returns (Common.VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(
            uint256(4625995678875839184227102343980957941553435037863367632170514069470978075482),
            uint256(7745472346822620166365670179252096531675980956628675937691452644416704349631)
        );
        vk.beta2 = Pairing.G2Point(
            [
                uint256(16133906051290029359415836500687237322258320219528941728637152470582101797559),
                uint256(9982592290591904397750372202184781412509742437847499064025507928193374812763)
            ],
            [
                uint256(20447084996628162496147084243623314997274147610235538549283479856317752366847),
                uint256(10652060452474388359080900509291122865897396777233890537481945528644944582649)
            ]
        );
        vk.gamma2 = Pairing.G2Point(
            [
                uint256(14205774305928561884273671177098614973303096843515928049981466843882075090453),
                uint256(6194647019556442694746623566240152360142526955447025858054760757353994166695)
            ],
            [
                uint256(720177741655577944140882804072173464461234581005085937938128202222496044348),
                uint256(15180859461535417805311870856102250988010112023636345871703449475067945282517)
            ]
        );
        vk.delta2 = Pairing.G2Point(
            [
                uint256(2075341858515413383107490988194322113274273165071779395977011288835607214232),
                uint256(21779842329350845285414688998042134519611654255235365675696046856282966715158)
            ],
            [
                uint256(4310903133868833376693610009744123646701594778591654462646551313203044329349),
                uint256(8934039419334185533732134671857943150009456594043165319933471646801466475060)
            ]
        );
    }

    /*
     * @returns Whether the proof is valid given the hardcoded verifying key
     *          above and the public inputs
     */
    function verifyCommitteeRootMappingProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[33] memory input
    ) public view returns (bool r) {
        Common.Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);

        // Make sure that proof.A, B, and C are each less than the prime q
        require(proof.A.X < PRIME_Q, "verifier-aX-gte-prime-q");
        require(proof.A.Y < PRIME_Q, "verifier-aY-gte-prime-q");

        require(proof.B.X[0] < PRIME_Q, "verifier-bX0-gte-prime-q");
        require(proof.B.Y[0] < PRIME_Q, "verifier-bY0-gte-prime-q");

        require(proof.B.X[1] < PRIME_Q, "verifier-bX1-gte-prime-q");
        require(proof.B.Y[1] < PRIME_Q, "verifier-bY1-gte-prime-q");

        require(proof.C.X < PRIME_Q, "verifier-cX-gte-prime-q");
        require(proof.C.Y < PRIME_Q, "verifier-cY-gte-prime-q");

        // Make sure that every input is less than the snark scalar field
        for (uint256 i = 0; i < input.length; i++) {
            require(input[i] < SNARK_SCALAR_FIELD, "verifier-gte-snark-scalar-field");
        }

        Common.VerifyingKey memory vk = verifyingKey1();

        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);

        // Buffer reused for addition p1 + p2 to avoid memory allocations
        // [0:2] -> p1.X, p1.Y ; [2:4] -> p2.X, p2.Y
        uint256[4] memory add_input;

        // Buffer reused for multiplication p1 * s
        // [0:2] -> p1.X, p1.Y ; [3] -> s
        uint256[3] memory mul_input;

        // temporary point to avoid extra allocations in accumulate
        Pairing.G1Point memory q = Pairing.G1Point(0, 0);

        vk_x.X = uint256(20552480178503420105472757749758256930777503163697981232418248899738739436302); // vk.K[0].X
        vk_x.Y = uint256(21874644052683447189335205444383300629386926406593895540736254865290692175330); // vk.K[0].Y
        mul_input[0] = uint256(2419465434811246925970456918943785845329721675292263546063218305166868830301); // vk.K[1].X
        mul_input[1] = uint256(224414837900933448241244127409926533084118787014653569685139207760162770563); // vk.K[1].Y
        mul_input[2] = input[0];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[1] * input[0]
        mul_input[0] = uint256(20237582094031100903111658800543003981446659818658320070287593450545147260932); // vk.K[2].X
        mul_input[1] = uint256(9498936270692258262448475366106441134297508170417707117017418182506243810929); // vk.K[2].Y
        mul_input[2] = input[1];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[2] * input[1]
        mul_input[0] = uint256(21686431407509598771022896245105442713057757617842882639916055310118549735455); // vk.K[3].X
        mul_input[1] = uint256(18587475580363988870337779644366478839186363821430368900189877147428300473925); // vk.K[3].Y
        mul_input[2] = input[2];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[3] * input[2]
        mul_input[0] = uint256(4190323520659374373641761976155873288531237902311450285189695279890286046705); // vk.K[4].X
        mul_input[1] = uint256(8044837422277408304807431419004307582225876792722238390231063677200212676904); // vk.K[4].Y
        mul_input[2] = input[3];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[4] * input[3]
        mul_input[0] = uint256(2652622379392044318082038991710242104342228971779836360052332572087628421201); // vk.K[5].X
        mul_input[1] = uint256(406860223885500452975843681654102213552218004006375181643914225581644355831); // vk.K[5].Y
        mul_input[2] = input[4];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[5] * input[4]
        mul_input[0] = uint256(6057918943482398019697118579402810827270820344972408585195554580949838772589); // vk.K[6].X
        mul_input[1] = uint256(5060377211716517826689871487122513539243478809827924728351043431363438746264); // vk.K[6].Y
        mul_input[2] = input[5];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[6] * input[5]
        mul_input[0] = uint256(3687702938753468537462497928786246235243684882237823906440956320376037461563); // vk.K[7].X
        mul_input[1] = uint256(1208686206265801496727901652555022795816232879429721718984614404615694111083); // vk.K[7].Y
        mul_input[2] = input[6];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[7] * input[6]
        mul_input[0] = uint256(11710614008104008246282861623202747769385618500144669344475214097509828684593); // vk.K[8].X
        mul_input[1] = uint256(5065836875015911503963590142184023993405575153173968399414211124081308802733); // vk.K[8].Y
        mul_input[2] = input[7];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[8] * input[7]
        mul_input[0] = uint256(544404787870686540959136485911507545335221912755631162384362056307403363961); // vk.K[9].X
        mul_input[1] = uint256(2345869893991024974950769006226913293849021455623995373213361343160988457751); // vk.K[9].Y
        mul_input[2] = input[8];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[9] * input[8]
        mul_input[0] = uint256(2209389364146280288951908471817129375141759543141552284740145921306411049406); // vk.K[10].X
        mul_input[1] = uint256(9042259349973012497614444570261244747029883119587798835387806797437998198439); // vk.K[10].Y
        mul_input[2] = input[9];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[10] * input[9]
        mul_input[0] = uint256(5329749415213215279150815169017002879660981652478899879932293459107956198272); // vk.K[11].X
        mul_input[1] = uint256(1269241490245981774317800992176787362067828005821041854984670483140659381972); // vk.K[11].Y
        mul_input[2] = input[10];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[11] * input[10]
        mul_input[0] = uint256(4943793813361186613838184379271444100858893499387902057809188182513783485846); // vk.K[12].X
        mul_input[1] = uint256(9275690329715777324103642003412034648418070562981699307031172873365106078545); // vk.K[12].Y
        mul_input[2] = input[11];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[12] * input[11]
        mul_input[0] = uint256(12729498268013982038852548044563174517696421517428254680176367740849220266709); // vk.K[13].X
        mul_input[1] = uint256(7546589572574852665535613703939452808321148398493753492131740521875420626909); // vk.K[13].Y
        mul_input[2] = input[12];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[13] * input[12]
        mul_input[0] = uint256(9333085734209829031122997463964247926338222396225058317742956090059153031592); // vk.K[14].X
        mul_input[1] = uint256(4043123151744068929699760825751364162242644369436915556155534564396462636465); // vk.K[14].Y
        mul_input[2] = input[13];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[14] * input[13]
        mul_input[0] = uint256(3698686717106590496650986585007797659650605418055308742433506982460764492730); // vk.K[15].X
        mul_input[1] = uint256(9179617523334761636265229485895993306228474412981061346064728177636515751968); // vk.K[15].Y
        mul_input[2] = input[14];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[15] * input[14]
        mul_input[0] = uint256(15521850592660810728436432508964964041834382081916421935161893482249902884387); // vk.K[16].X
        mul_input[1] = uint256(5449901017503560405242500659614777785834634841695450826672263537767974100219); // vk.K[16].Y
        mul_input[2] = input[15];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[16] * input[15]
        mul_input[0] = uint256(20102906107256118088436001377164222872704427733042089123636772674622559816716); // vk.K[17].X
        mul_input[1] = uint256(12498854682789208487185327670228889940757953195079617884138082484806034246784); // vk.K[17].Y
        mul_input[2] = input[16];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[17] * input[16]
        mul_input[0] = uint256(9455841695606475800176819517076441035373288808813491909032241063291148788930); // vk.K[18].X
        mul_input[1] = uint256(5760837211388967374979882368837632355372021503182733102840122488409476353553); // vk.K[18].Y
        mul_input[2] = input[17];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[18] * input[17]
        mul_input[0] = uint256(1446991383552871512734012954692326283314249519870143612600792757960520781278); // vk.K[19].X
        mul_input[1] = uint256(9834470268591454131741863361237282178002203711883219940241340793939995038767); // vk.K[19].Y
        mul_input[2] = input[18];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[19] * input[18]
        mul_input[0] = uint256(1059357485615144832413353841149751938707953460935522780194084907196702253731); // vk.K[20].X
        mul_input[1] = uint256(10815569476482003993766770423385630209543201328293985898718647153832884016017); // vk.K[20].Y
        mul_input[2] = input[19];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[20] * input[19]
        mul_input[0] = uint256(7433245970798099608332042376067563625513377267096206052430761000239299269566); // vk.K[21].X
        mul_input[1] = uint256(12741834193487831964894419250386047831198155854304448707022734193570700410821); // vk.K[21].Y
        mul_input[2] = input[20];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[21] * input[20]
        mul_input[0] = uint256(8648224634225961431530490440075030243542463588893169022877288417966438069777); // vk.K[22].X
        mul_input[1] = uint256(16540610842070555034877322476339116325277917786072762919274678110762172365508); // vk.K[22].Y
        mul_input[2] = input[21];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[22] * input[21]
        mul_input[0] = uint256(16908648218709781420138074614673957046034248547088691701260866141074824824919); // vk.K[23].X
        mul_input[1] = uint256(20980273428957053574278769661356962533672481733183512384951407225298181139010); // vk.K[23].Y
        mul_input[2] = input[22];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[23] * input[22]
        mul_input[0] = uint256(20934252423600973663175987808002009495824217352345209099319606411155218995932); // vk.K[24].X
        mul_input[1] = uint256(9987927206019920292163635872827487165514620975045002130414615160938718715749); // vk.K[24].Y
        mul_input[2] = input[23];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[24] * input[23]
        mul_input[0] = uint256(9602737041922572073213386264444643405537681976425696147506639312256088109115); // vk.K[25].X
        mul_input[1] = uint256(5030838233095700558123674330813925820525997306253984515590208165812087573689); // vk.K[25].Y
        mul_input[2] = input[24];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[25] * input[24]
        mul_input[0] = uint256(20088832978375886523413495106079569725269630343909328763686584839952109161933); // vk.K[26].X
        mul_input[1] = uint256(8311397503596416021728705867174781915782892850820869993294450806608979293432); // vk.K[26].Y
        mul_input[2] = input[25];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[26] * input[25]
        mul_input[0] = uint256(15729968276421379987872047780863974781795109674620595131198333451598870913212); // vk.K[27].X
        mul_input[1] = uint256(11755585053459843437112320638816029546922021127794137048950074210155862560131); // vk.K[27].Y
        mul_input[2] = input[26];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[27] * input[26]
        mul_input[0] = uint256(5783930197610380391486193680213891260111080319012345925622032738683845648623); // vk.K[28].X
        mul_input[1] = uint256(15914052883335873414184612431500787588848752068877353731383121390711998005745); // vk.K[28].Y
        mul_input[2] = input[27];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[28] * input[27]
        mul_input[0] = uint256(13576027419855184371737615151659181815220661446877879847199764825219880625500); // vk.K[29].X
        mul_input[1] = uint256(2191728030944522062213775267825510142676636904535936426097088151735038661017); // vk.K[29].Y
        mul_input[2] = input[28];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[29] * input[28]
        mul_input[0] = uint256(17443744306907421274656073114832682866914815795994710278637727590770342132904); // vk.K[30].X
        mul_input[1] = uint256(6204265850197846880732314988280474321915051365218910504902500465319260176648); // vk.K[30].Y
        mul_input[2] = input[29];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[30] * input[29]
        mul_input[0] = uint256(7667236600173703281656707827902729453577123223272717952708859478183847798002); // vk.K[31].X
        mul_input[1] = uint256(3073364345901477288521870238026227645583520851820532416933060479253244595356); // vk.K[31].Y
        mul_input[2] = input[30];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[31] * input[30]
        mul_input[0] = uint256(9980877541970177898146397507672456369445448128646497326829193893755401659297); // vk.K[32].X
        mul_input[1] = uint256(11845859001496825643147981605740249183632753870257747701403057774143489519069); // vk.K[32].Y
        mul_input[2] = input[31];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[32] * input[31]
        mul_input[0] = uint256(12453897189547283279636360437482740153245209912090247350145743599538029507132); // vk.K[33].X
        mul_input[1] = uint256(6469937287375115226432040539121250021511388797917475330256634615436829876816); // vk.K[33].Y
        mul_input[2] = input[32];
        Common.accumulate(mul_input, q, add_input, vk_x); // vk_x += vk.K[33] * input[32]

        return
            Pairing.pairing(Pairing.negate(proof.A), proof.B, vk.alfa1, vk.beta2, vk_x, vk.gamma2, proof.C, vk.delta2);
    }
}

// SPDX-License-Identifier: AML

pragma solidity ^0.8.0;

import "./Pairing.sol";

library Common {
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        // []G1Point IC (K in gnark) appears directly in verifyProof
    }

    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }

    // accumulate scalarMul(mul_input) into q
    // that is computes sets q = (mul_input[0:2] * mul_input[3]) + q
    function accumulate(
        uint256[3] memory mul_input,
        Pairing.G1Point memory p,
        uint256[4] memory buffer,
        Pairing.G1Point memory q
    ) internal view {
        // computes p = mul_input[0:2] * mul_input[3]
        Pairing.scalar_mul_raw(mul_input, p);

        // point addition inputs
        buffer[0] = q.X;
        buffer[1] = q.Y;
        buffer[2] = p.X;
        buffer[3] = p.Y;

        // q = p + q
        Pairing.plus_raw(buffer, q);
    }
}

// SPDX-License-Identifier: AML

pragma solidity ^0.8.0;

uint256 constant SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

// SPDX-License-Identifier: AML
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

// 2019 OKIMS

pragma solidity ^0.8.0;

library Pairing {
    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    struct G1Point {
        uint256 X;
        uint256 Y;
    }

    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    /*
     * @return The negation of p, i.e. p.plus(p.negate()) should be zero.
     */
    function negate(G1Point memory p) internal pure returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        if (p.X == 0 && p.Y == 0) {
            return G1Point(0, 0);
        } else {
            return G1Point(p.X, PRIME_Q - (p.Y % PRIME_Q));
        }
    }

    /*
     * @return The sum of two points of G1
     */
    function plus(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint256[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }

        require(success, "pairing-add-failed");
    }

    /*
     * Same as plus but accepts raw input instead of struct
     * @return The sum of two points of G1, one is represented as array
     */
    function plus_raw(uint256[4] memory input, G1Point memory r) internal view {
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }

        require(success, "pairing-add-failed");
    }

    /*
     * @return The product of a point on G1 and a scalar, i.e.
     *         p == p.scalar_mul(1) and p.plus(p) == p.scalar_mul(2) for all
     *         points p.
     */
    function scalar_mul(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {
        uint256[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }
        require(success, "pairing-mul-failed");
    }

    /*
     * Same as scalar_mul but accepts raw input instead of struct,
     * Which avoid extra allocation. provided input can be allocated outside and re-used multiple times
     */
    function scalar_mul_raw(uint256[3] memory input, G1Point memory r) internal view {
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }
        require(success, "pairing-mul-failed");
    }

    /* @return The result of computing the pairing check
     *         e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
     *         For example,
     *         pairing([P1(), P1().negate()], [P2(), P2()]) should return true.
     */
    function pairing(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2,
        G1Point memory d1,
        G2Point memory d2
    ) internal view returns (bool) {
        G1Point[4] memory p1 = [a1, b1, c1, d1];
        G2Point[4] memory p2 = [a2, b2, c2, d2];
        uint256 inputSize = 24;
        uint256[] memory input = new uint256[](inputSize);

        for (uint256 i = 0; i < 4; i++) {
            uint256 j = i * 6;
            input[j + 0] = p1[i].X;
            input[j + 1] = p1[i].Y;
            input[j + 2] = p2[i].X[0];
            input[j + 3] = p2[i].X[1];
            input[j + 4] = p2[i].Y[0];
            input[j + 5] = p2[i].Y[1];
        }

        uint256[1] memory out;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }

        require(success, "pairing-opcode-failed");

        return out[0] != 0;
    }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.18;

import "../Types.sol";
import "./BlsSigVerifier.sol";
import "./CommitteeRootMappingVerifier.sol";

contract ZkVerifier is BlsSigVerifier, CommitteeRootMappingVerifier {
    function verifySignatureProof(
        bytes32 signingRoot,
        bytes32 syncCommitteePoseidonRoot,
        uint256 participation,
        Proof memory p
    ) public view returns (bool) {
        uint256[34] memory input;
        uint256 root = uint256(signingRoot);
        // slice the signing root into 32 individual bytes and assign them in order to the first 32 slots of input[]
        for (uint256 i = 0; i < 32; i++) {
            input[(32 - 1 - i)] = root % 256;
            root = root / 256;
        }
        input[32] = participation;
        input[33] = uint256(syncCommitteePoseidonRoot);
        return verifyBlsSigProof(p.a, p.b, p.c, input);
    }

    function verifySyncCommitteeRootMappingProof(
        bytes32 sszRoot,
        bytes32 poseidonRoot,
        Proof memory p
    ) public view returns (bool) {
        uint256[33] memory input;
        uint256 root = uint256(sszRoot);
        for (uint256 i = 0; i < 32; i++) {
            input[(32 - 1 - i)] = root % 256;
            root = root / 256;
        }
        input[32] = uint256(poseidonRoot);
        return verifyCommitteeRootMappingProof(p.a, p.b, p.c, input);
    }
}