---
title: Rotate and translate
author: Marcus
date: 2016-10-10T00:00:00+00:00
math: true
categories:
  - Math

---

If you rotate a 2-dim. figure around two different center points with
the same angle, you need an extra translation to move the images into
the same position.

For simplicity, we assume that one center is the origin, and the other
is $c=(c_x, c_y, 1)^T$ (homogeneous coordinates in projective space).
Let's determine the equations to convert the rotation $R$ around $c$
into a rotation around the origin $O=(0,0, 1)^T$, followed by a translation
$t=(t_x, t_y, 1)^T$.  With

$$
  R = \begin{pmatrix} \cos \alpha & \sin \alpha & 0 \\\ -\sin \alpha & \cos \alpha & 0 \\\ 0 & 0 & 1 \end{pmatrix},
  T = \begin{pmatrix} 1 & 0 & t_x \\\ 0 & 1 & t_y \\\ 0 & 0 & 1 \end{pmatrix},
  C = \begin{pmatrix} 1 & 0 & c_x \\\ 0 & 1 & c_y \\\ 0 & 0 & 1 \end{pmatrix},
$$

we have for all $v$:

$$
  CR(-C)v = TRv
$$

Expanding the matrices yields:

$$
  \begin{pmatrix} \cos \alpha & \sin \alpha & -c_x\cos\alpha - c_y\sin\alpha + c_x \\\ -\sin \alpha & \cos \alpha & c_x\sin\alpha - c_y\cos\alpha + c_y \\\ 0 & 0 & 1 \end{pmatrix}v =
  \begin{pmatrix} \cos \alpha & \sin \alpha & t_x \\\ -\sin \alpha & \cos \alpha & t_y \\\ 0 & 0 & 1 \end{pmatrix}v
$$

So we are left with equations that define $t$ as the image of the origin:

<p>
$$
\begin{align}
  t_x &= c_x(1-\cos\alpha) - c_y\sin\alpha \\\
  t_y &= c_x\sin\alpha + c_y(1 - \cos\alpha)
\end{align}
$$
</p>

Solving first eq. for $c_y$:

$$
  c_y = c_x\frac{1-\cos\alpha}{\sin\alpha}-\frac{t_x}{\sin\alpha} = c_x\tan\frac\alpha2-\frac{t_x}{\sin\alpha}
$$

And inserting in second eq., solving for $c_x$:

<p>
$$
\begin{align}
  t_y &= c_x\sin\alpha + \left(c_x\tan\frac\alpha2-\frac{t_x}{\sin\alpha}\right)(1-\cos\alpha) \\\
  t_y &= c_x\left(\sin\alpha+(1-\cos\alpha)\tan\frac\alpha2\right) - t_x\tan\frac\alpha2 \\\
  t_y &= 2c_x\tan\frac\alpha2 - t_x\tan\frac\alpha2 \\\
 \Rightarrow  c_x &= \frac12\left(t_x + t_y\cot\frac\alpha2 \right), \\\
  	      c_y &= \frac12\left(t_y - t_x\cot\frac\alpha2 \right)
\end{align}
$$
</p>

Using this lemma:

<p>
$$
\begin{align}
  \sin\alpha+(1-\cos\alpha)\tan\frac\alpha2
  &= \sin\alpha+\frac{(1-\cos\alpha)^2}{\sin\alpha} \\\
  &= \frac{\sin^2\alpha+1-2\cos\alpha + \cos^2\alpha}{\sin\alpha} = \frac{2(1-\cos\alpha)}{\sin\alpha}=2\tan\frac\alpha2
\end{align}
$$
</p>

Geometrically, you can find the center to a translation by choosing
two points, connect them to their respective images, and take the line
segment bisectors.  The intersection of the bisectors is the point
that is equidistant to all (point, image point) pairs.

Here is an illustration showing only one point and its image, the
corresponding bisector, and the resulting equation for $c_y$:

{{< figure src="/images/2016/rottrans.png" >}}
