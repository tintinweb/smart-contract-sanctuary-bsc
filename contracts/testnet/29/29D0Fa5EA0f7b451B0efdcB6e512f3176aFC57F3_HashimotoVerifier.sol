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
    function plus(
        G1Point memory p1,
        G1Point memory p2
    ) internal view returns (G1Point memory r) {

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
            switch success case 0 { invalid() }
        }

        require(success,"pairing-add-failed");
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
            switch success case 0 { invalid() }
        }
        require (success,"pairing-mul-failed");
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
            switch success case 0 { invalid() }
        }

        require(success,"pairing-opcode-failed");

        return out[0] != 0;
    }
}

contract HashimotoVerifier {

    using Pairing for *;

    uint256 constant SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[15] IC;
    }

    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(uint256(16756621027450210638949164556971271062079039403126368073820222665309440250760), uint256(3534133503491448695144816997722694748290912851714520985942449362294578331227));
        vk.beta2 = Pairing.G2Point([uint256(16578367437499285862797787078951442515068285412519924919744464560702395366047), uint256(11238961074023776129419765288254433020748162638845191551270208116747611932398)], [uint256(16753087078475159160894613062940361541918161430836208856163905210332786154582), uint256(2820985669501963637494632811484507217336590859205542289103383247580773302353)]);
        vk.gamma2 = Pairing.G2Point([uint256(8002329963477232889848814180904739341690910301873615328144103926316921726163), uint256(10226423241039136383288784740697983990610239530436620762007146582994883456234)], [uint256(19786661023984958041257365573082363808007886911151073613377107474257501256110), uint256(21064575404241297400091940923142081128702138839219302187815733719575985553232)]);
        vk.delta2 = Pairing.G2Point([uint256(5643238999640522733643448458218704494196203835674192764084323108367178938891), uint256(16700902248467009170467937587813453372287356974012743617216489288657558869015)], [uint256(19940225148331008836027570107550898336794843376675881968468498723183907795088), uint256(15667808865171125348808096562877016471962861845848148581478588640573194179693)]);   
        vk.IC[0] = Pairing.G1Point(uint256(10256516457746509358657274363728241060868436764381359614437030511425220236640), uint256(19142697576167121187810365193256330554589546508871235262002741679219819540802));   
        vk.IC[1] = Pairing.G1Point(uint256(4061098604354593227891079526965115858288279897931595988499096309901601382787), uint256(17511304642512653852219116799675583176016056234391984129245267035312477562285));   
        vk.IC[2] = Pairing.G1Point(uint256(3662576565662383278658449072292918192718326701531262011376974603664024517159), uint256(19884524250956481560769300589869294679603258376094152249997574351440140853285));   
        vk.IC[3] = Pairing.G1Point(uint256(5306133835406099865447489751858562577920059735141949429251492615983406123826), uint256(1766197564139055704846019924365442018797953033902899688109450397143942618807));   
        vk.IC[4] = Pairing.G1Point(uint256(5395740264858625575891201673523935906837161867899102325001906315502376521633), uint256(18847192459138090134448374901554250511075966958907933780048204924343235266174));   
        vk.IC[5] = Pairing.G1Point(uint256(322528029680592352901591592817439713007453825807898968260238100018548193476), uint256(5551428067697428266660864727666196715430719246610943663793098281401830883453));   
        vk.IC[6] = Pairing.G1Point(uint256(20688090713059744040494636322118674455754081496003190544584985165151438839302), uint256(8785651095531888149800858460664218303000753515827309789388326325734927172279));   
        vk.IC[7] = Pairing.G1Point(uint256(15800598509776051344470132238255814697532064141796173675146740710409010897180), uint256(16556740402014959980078238002720339725283519626372765498324494824542780885890));   
        vk.IC[8] = Pairing.G1Point(uint256(7939136586947254231957509698127195671686340870899727215940199917161057654414), uint256(11428293301332937445999940914057023104584791055113339306341356141134148853483));   
        vk.IC[9] = Pairing.G1Point(uint256(568041367040398267522102744967996296733595732797826518008712712606466978510), uint256(6595937154321922563352808825294146817362165519481372499900066453706837001333));   
        vk.IC[10] = Pairing.G1Point(uint256(15825903019546343755792117004376701089375246318880506626713987911529732478126), uint256(15876345013017833479130522788802990809130298522812136342120256379026034198536));   
        vk.IC[11] = Pairing.G1Point(uint256(1214037055039203324129009971539011489761199111379649858788318147117463360095), uint256(2693423051122406842504594220423740174939915810002042779197522418528273460279));   
        vk.IC[12] = Pairing.G1Point(uint256(3194038676189983241512883976294978437234217714216264469647266979006915410041), uint256(16870303610665554182383820000832035943241868345869954964602847568203623830273));   
        vk.IC[13] = Pairing.G1Point(uint256(8646334243935649525588433496419044817958039408487703194734749863032425830629), uint256(17925388334528358897105131001505351841583115055171257802494158774801496003653));   
        vk.IC[14] = Pairing.G1Point(uint256(5362877395152881258348217379460779973438710282772858296085400385648911621019), uint256(11565404606797205881494828941580958212500128983074980606596750730104140325860));
    }
    
    /*
     * @returns Whether the proof is valid given the hardcoded verifying key
     *          above and the public inputs
     */
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[14] memory input
    ) public view returns (bool r) {

        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);

        VerifyingKey memory vk = verifyingKey();

        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);

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
            require(input[i] < SNARK_SCALAR_FIELD,"verifier-gte-snark-scalar-field");
            vk_x = Pairing.plus(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }

        vk_x = Pairing.plus(vk_x, vk.IC[0]);

        return Pairing.pairing(
            Pairing.negate(proof.A),
            proof.B,
            vk.alfa1,
            vk.beta2,
            vk_x,
            vk.gamma2,
            proof.C,
            vk.delta2
        );
    }
}