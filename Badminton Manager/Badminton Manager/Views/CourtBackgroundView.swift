//
//  CourtBackgroundView.swift
//  Badminton Manager
//
//  Created by Sajev Lucksman on 2026-07-04.
//

import SwiftUI

struct CourtBackgroundView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cw = w * 0.90
            let ch = h * 0.72
            let ox = (w - cw) / 2
            let oy = (h - ch) / 2
            let lc = Color.white.opacity(0.04)
            let lw: CGFloat = 2.0

            Canvas { ctx, _ in
                // Court area
                let courtRect = CGRect(x: ox, y: oy, width: cw, height: ch)
                ctx.fill(Path(roundedRect: courtRect, cornerRadius: 4), with: .color(Color.white.opacity(0.015)))

                // Outer boundary
                var outer = Path()
                outer.addRoundedRect(in: courtRect, cornerSize: CGSize(width: 4, height: 4))
                ctx.stroke(outer, with: .color(lc), lineWidth: lw)

                // Singles sidelines
                let si = cw * 0.075
                var ls = Path(); ls.move(to: CGPoint(x: ox + si, y: oy)); ls.addLine(to: CGPoint(x: ox + si, y: oy + ch))
                ctx.stroke(ls, with: .color(lc), lineWidth: lw)
                var rs = Path(); rs.move(to: CGPoint(x: ox + cw - si, y: oy)); rs.addLine(to: CGPoint(x: ox + cw - si, y: oy + ch))
                ctx.stroke(rs, with: .color(lc), lineWidth: lw)

                // Net line
                let cy = oy + ch / 2
                var net = Path(); net.move(to: CGPoint(x: ox - 6, y: cy)); net.addLine(to: CGPoint(x: ox + cw + 6, y: cy))
                ctx.stroke(net, with: .color(Color.white.opacity(0.06)), lineWidth: lw * 1.5)

                // Service lines
                let sd = ch * 0.148
                var ts = Path(); ts.move(to: CGPoint(x: ox, y: cy - sd)); ts.addLine(to: CGPoint(x: ox + cw, y: cy - sd))
                ctx.stroke(ts, with: .color(lc), lineWidth: lw)
                var bs = Path(); bs.move(to: CGPoint(x: ox, y: cy + sd)); bs.addLine(to: CGPoint(x: ox + cw, y: cy + sd))
                ctx.stroke(bs, with: .color(lc), lineWidth: lw)

                // Long service lines
                let ld = ch * 0.057
                var tl = Path(); tl.move(to: CGPoint(x: ox, y: oy + ld)); tl.addLine(to: CGPoint(x: ox + cw, y: oy + ld))
                ctx.stroke(tl, with: .color(lc), lineWidth: lw)
                var bl = Path(); bl.move(to: CGPoint(x: ox, y: oy + ch - ld)); bl.addLine(to: CGPoint(x: ox + cw, y: oy + ch - ld))
                ctx.stroke(bl, with: .color(lc), lineWidth: lw)

                // Center lines
                let cx = ox + cw / 2
                var tc = Path(); tc.move(to: CGPoint(x: cx, y: oy)); tc.addLine(to: CGPoint(x: cx, y: cy - sd))
                ctx.stroke(tc, with: .color(lc), lineWidth: lw)
                var bc = Path(); bc.move(to: CGPoint(x: cx, y: cy + sd)); bc.addLine(to: CGPoint(x: cx, y: oy + ch))
                ctx.stroke(bc, with: .color(lc), lineWidth: lw)
            }
        }
    }
}
