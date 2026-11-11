
`default_nettype none

module tt_um_vga_example(
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // =====================================
    // VGA
    // =====================================

    wire hsync;
    wire vsync;
    wire video_active;

    wire [9:0] pix_x;
    wire [9:0] pix_y;

    reg [1:0] R;
    reg [1:0] G;
    reg [1:0] B;

    assign uo_out = {
        hsync,
        B[0], G[0], R[0],
        vsync,
        B[1], G[1], R[1]
    };

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire _unused_ok = &{ena, ui_in, uio_in};

    hvsync_generator hvsync_gen(
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(video_active),
        .hpos(pix_x),
        .vpos(pix_y)
    );

    // =====================================
    // CONTROL DE ANIMACION
    // =====================================

    reg [3:0] frame_count;
    reg [2:0] step;

    always @(posedge vsync or negedge rst_n) begin
        if (!rst_n) begin
            frame_count <= 4'd0;
            step <= 3'd0;
        end
        else begin
            if (frame_count == 4'd11) begin
                frame_count <= 4'd0;
                step <= step + 3'd1;
            end
            else begin
                frame_count <= frame_count + 4'd1;
            end
        end
    end

    // =====================================
    // CENTRO DE LA PANTALLA
    // =====================================

    wire signed [10:0] dx =
        $signed({1'b0, pix_x}) - 11'sd320;

    wire signed [10:0] dy =
        $signed({1'b0, pix_y}) - 11'sd240;

    wire [10:0] ax =
        dx[10] ? -dx : dx;

    wire [10:0] ay =
        dy[10] ? -dy : dy;

    // =====================================
    // CIRCULOS REALES
    // =====================================

    wire [21:0] x2 = ax * ax;
    wire [21:0] y2 = ay * ay;

    wire [22:0] radius2 =
        {1'b0, x2} + {1'b0, y2};

    // =====================================
    // CINCO AROS
    // =====================================

    reg [2:0] ring;
    reg in_ring;

    always @(*) begin

        ring = 3'd0;
        in_ring = 1'b1;

        // Aro 1: radio 25 a 40
        if (radius2 >= 23'd100 &&
            radius2 < 23'd3600)
            ring = 3'd0;

        // Aro 2: radio 50 a 65
        else if (radius2 >= 23'd3600 &&
                 radius2 < 23'd10000)
            ring = 3'd1;

        // Aro 3: radio 75 a 90
        else if (radius2 >= 23'd10000 &&
                 radius2 < 23'd19600)
            ring = 3'd2;

        // Aro 4: radio 100 a 115
        else if (radius2 >= 23'd19600 &&
                 radius2 < 23'd32400)
            ring = 3'd3;

        // Aro 5: radio 125 a 140
        else if (radius2 >= 23'd32400 &&
                 radius2 < 23'd48400)
            ring = 3'd4;

        else begin
            ring = 3'd0;
            in_ring = 1'b0;
        end
    end

    // =====================================
    // 8 SECTORES DE 45 GRADOS
    //
    // Numerados en sentido horario
    // desde el eje horizontal derecho.
    //
    // 0 = derecha a abajo-diagonal
    // 1 = abajo-diagonal a abajo
    // 2 = abajo a abajo-izquierda
    // 3 = abajo-izquierda a izquierda
    // 4 = izquierda a arriba-izquierda
    // 5 = arriba-izquierda a arriba
    // 6 = arriba a arriba-derecha
    // 7 = arriba-derecha a derecha
    // =====================================

    reg [2:0] sector;

    always @(*) begin

        sector = 3'd0;

        if (!dx[10] && !dy[10]) begin

            // Cuadrante inferior derecho
            if (ax >= ay)
                sector = 3'd0;
            else
                sector = 3'd1;

        end
        else if (dx[10] && !dy[10]) begin

            // Cuadrante inferior izquierdo
            if (ay >= ax)
                sector = 3'd2;
            else
                sector = 3'd3;

        end
        else if (dx[10] && dy[10]) begin

            // Cuadrante superior izquierdo
            if (ax >= ay)
                sector = 3'd4;
            else
                sector = 3'd5;

        end
        else begin

            // Cuadrante superior derecho
            if (ay >= ax)
                sector = 3'd6;
            else
                sector = 3'd7;

        end
    end

    // =====================================
    // MOVIMIENTO ALTERNADO
    //
    // Aros pares (0,2,4): horario
    // Aros impares (1,3): antihorario
    // =====================================

    wire [2:0] active_sector =
        ring[0] ? (3'd0 - step) : step;

    wire highlighted =
        in_ring && (sector == active_sector);

    // =====================================
    // COLORES MATE
    // =====================================

    always @(*) begin

        R = 2'b00;
        G = 2'b00;
        B = 2'b00;

        if (video_active && in_ring) begin

            case (ring)

                // ARO 1 - ROJO MATE
                3'd0: begin
                    if (highlighted) begin
                        R = 2'b11;
                        G = 2'b01;
                        B = 2'b01;
                    end
                    else begin
                        R = 2'b00;
                        G = 2'b00;
                        B = 2'b00;
                    end
                end

                // ARO 2 - NARANJA MATE
                3'd1: begin
                    if (highlighted) begin
                        R = 2'b11;
                        G = 2'b10;
                        B = 2'b00;
                    end
                    else begin
                        R = 2'b00;
                        G = 2'b00;
                        B = 2'b00;
                    end
                end

                // ARO 3 - VERDE MATE
                3'd2: begin
                    if (highlighted) begin
                        R = 2'b01;
                        G = 2'b11;
                        B = 2'b01;
                    end
                    else begin
                        R = 2'b00;
                        G = 2'b00;
                        B = 2'b00;
                    end
                end

                // ARO 4 - CYAN MATE
                3'd3: begin
                    if (highlighted) begin
                        R = 2'b00;
                        G = 2'b11;
                        B = 2'b11;
                    end
                    else begin
                        R = 2'b00;
                        G = 2'b00;
                        B = 2'b00;
                    end
                end

                // ARO 5 - VIOLETA MATE
                3'd4: begin
                    if (highlighted) begin
                        R = 2'b10;
                        G = 2'b01;
                        B = 2'b11;
                    end
                    else begin
                        R = 2'b00;
                        G = 2'b00;
                        B = 2'b00;
                    end
                end

                default: begin
                    R = 2'b00;
                    G = 2'b00;
                    B = 2'b00;
                end

            endcase
        end
    end

endmodule

`default_nettype wire
